//
//  RequestHandler.swift
//
//  Created by Lincoln Fraley on 12/4/18.
//

import Foundation
import Alamofire

protocol HTTPRequester {
    
    func request(
        _ request: URLRequest,
        _ completion: ((_ error: Error?, _ response: HTTPURLResponse?, _ data: Data?) -> Void)?)
        -> Void
}

fileprivate final class AlamofireHTTPRequester {
    
    static let shared = AlamofireHTTPRequester()
    fileprivate static let sessionManager: SessionManager = {
        var sessionManager = SessionManager(configuration: .default)
        sessionManager.retrier = RequestHandler.shared
        sessionManager.adapter = RequestHandler.shared
        return sessionManager
    }()
    
    private init() {}
}

extension AlamofireHTTPRequester: HTTPRequester {
    
    func request(
        _ request: URLRequest,
        _ completion: ((Error?, HTTPURLResponse?, Data?) -> Void)?)
        -> Void
    {
        AlamofireHTTPRequester.sessionManager
            .request(request)
            .validate(statusCode: 200..<300)
            .response { completion?($0.error, $0.response, $0.data) }
    }
}

final class RequestHandler {
    
    static let shared = RequestHandler()
    private let requester: HTTPRequester = AlamofireHTTPRequester.shared
    private let lock = NSLock()
    private var requestsToRetry = [RequestRetryCompletion]()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.dynepic.playPORTAL.RequestManagerQueue", attributes: .concurrent)
    private var isRefreshing = false
    
    private let accessTokenKey = "\(PlayPortalAuth.shared.appId)-PPSDK-accessToken"
    private(set) var accessToken: String? {
        get { return queue.sync { globalStorageHandler.get(accessTokenKey) }}
        set(accessToken) {
            if let accessToken = accessToken {
                queue.async(flags: .barrier) { globalStorageHandler.set(accessToken, atKey: self.accessTokenKey) }
            }
        }
    }
    
    private let refreshTokenKey = "\(PlayPortalAuth.shared.appId)-PPSDK-refreshToken"
    private(set) var refreshToken: String? {
        get { return queue.sync { globalStorageHandler.get(refreshTokenKey) }}
        set(refreshToken) {
            if let refreshToken = refreshToken {
                queue.async(flags: .barrier) { globalStorageHandler.set(refreshToken, atKey: self.refreshTokenKey) }
            }
        }
    }
    var isAuthenticated: Bool {
        get { return accessToken != nil && refreshToken != nil }
    }
    
    private init() { }
    
    deinit {
        EventHandler.shared.unsubscribe(self)
    }
    
    func deleteKeys() {
        globalStorageHandler.delete(accessTokenKey)
        globalStorageHandler.delete(refreshTokenKey)
    }
    
    // This isn't great but oh well
    func createAnonymousUser(
        _ request: PPSDK_Swift.URLRequestConvertible,
        _ completion: @escaping (_ error: Error?, _ anonymousProfile: PlayPortalProfile?) -> Void)
        -> Void
    {
        var request = request.asURLRequest()
        if let accessToken = accessToken {
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        requester.request(request) { error, response, data in
            if let error = response.flatMap({ PlayPortalError.API.createError(from: $0) }) {
                completion(error, nil)
            } else if error != nil {
                completion(error, nil)
            } else {
                guard let accessToken = response?.allHeaderFields["access_token"] as? String
                    , let refreshToken = response?.allHeaderFields["refresh_token"] as? String
                    else {
                        return completion(PlayPortalError.API.requestFailedForUnknownReason(message: "Could not retrieve tokens from response headers."), nil)
                }
                self.accessToken = accessToken
                self.refreshToken = refreshToken
                let anonymousProfile = data?.asJSON
                    .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) }
                    .flatMap { try? self.decoder.decode(PlayPortalProfile.self, from: $0) }
                let err = anonymousProfile == nil ? PlayPortalError.API.unableToDeserializeResponse : nil
                completion(err, anonymousProfile)
            }
        }
    }
    
    private func _request(
        _ request: PPSDK_Swift.URLRequestConvertible,
        at keyPath: String? = nil,
        _ completion: ((_ error: Error?, _ result: Any?) -> Void)?)
        -> Void
    {
        var request = request.asURLRequest()
        if let accessToken = accessToken {
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        requester.request(request) { error, response, data in
            if let error = response.flatMap({ PlayPortalError.API.createError(from: $0) }) {
                completion?(error, nil)
            } else if error != nil {
                completion?(error, nil)
            } else {
                var result = data as Any?
                if let json = data?.asJSON {
                    var value: Any = json
                    if let keys = keyPath?.split(separator: ".").map(String.init) {
                        value = json.valueAtNestedKey(keys)
                    }
                    if JSONSerialization.isValidJSONObject(value) {
                        result = (try? JSONSerialization.data(withJSONObject: ["result": value], options: .prettyPrinted))?.asJSON?["result"]
                    }
                }
                completion?(nil, result)
            }
        }
    }
    
    func request(
        _ request: PPSDK_Swift.URLRequestConvertible,
        at keyPath: String? = nil,
        _ completion: ((_ error: Error?, _ result: Any?) -> Void)?)
        -> Void
    {
        _request(request, at: keyPath, completion)
    }
    
    func request(
        _ request: PPSDK_Swift.URLRequestConvertible,
        at keyPath: String? = nil,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        _request(request, at: keyPath) { error, _ in
            completion?(error)
        }
    }
    
    func request<Result: Codable>(
        _ request: PPSDK_Swift.URLRequestConvertible,
        at keyPath: String? = nil,
        _ completion: ((_ error: Error?, _ result: Result?) -> Void)?)
        -> Void
    {
        _request(request, at: keyPath) { error, result in
            if let error = error {
                completion?(error, nil)
            } else if result == nil {
                completion?(PlayPortalError.API.unableToDeserializeResponse, nil)
            } else {
                let result: Result? = {
                    switch Result.self {
                    case is Data.Type:
                        return result as? Result
                    default:
                        return (try? JSONSerialization.data(withJSONObject: result!, options: .prettyPrinted))
                            .flatMap { try? self.decoder.decode(Result.self, from: $0) }
                    }
                }()
                let err = result == nil ? PlayPortalError.API.unableToDeserializeResponse : nil
                completion?(err, result)
            }
        }
    }
}

extension RequestHandler: EventSubscriber {
    
    func on(event: Event) {
        switch event {
        case let .authenticated(accessToken, refreshToken):
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        case .firstRun:
            globalStorageHandler.delete(accessTokenKey)
            globalStorageHandler.delete(refreshTokenKey)
        case .loggedOut:
            globalStorageHandler.delete(accessTokenKey)
            globalStorageHandler.delete(refreshTokenKey)
        }
    }
}

extension RequestHandler: RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        if let accessToken = accessToken {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}

extension RequestHandler: RequestRetrier {
    
    func should(
        _ manager: SessionManager,
        retry request: Request,
        with error: Error,
        completion: @escaping RequestRetryCompletion)
    {
        lock.lock(); defer { lock.unlock() }
        requestsToRetry.append(completion)
        
        if let response = request.task?.response as? HTTPURLResponse,
            PlayPortalError.API.ErrorCode.errorCode(for: response) == .tokenRefreshRequired {
            if !isRefreshing {
                isRefreshing = true
                guard let accessToken = accessToken, let refreshToken = refreshToken else {
                    completion(false, 0.0)
                    return
                }
                PlayPortalAuth.shared.refresh(accessToken: accessToken, refreshToken: refreshToken) { error, accessToken, refreshToken in
                    self.lock.lock(); defer { self.lock.unlock() }
                    self.accessToken = accessToken
                    self.refreshToken = refreshToken
                    self.requestsToRetry.forEach { $0(error == nil, 0.0) }
                    self.requestsToRetry.removeAll()
                    self.isRefreshing = false
                    if error != nil {
                        EventHandler.shared.publish(.loggedOut(error: error))
                    }
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
}
