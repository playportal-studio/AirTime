//
//  AlamofireRequestHandler.swift
//
//  Created by Lincoln Fraley on 10/25/18.
//

import Foundation
import Alamofire

//  Class implementing `RequestHandler` and using Alamofire internally
class AlamofireRequestHandler {
    
    //  MARK: - Properties
    
    //  Singleton instance
    static let shared = AlamofireRequestHandler()
    
    //  `SessionManager` instance
    fileprivate static let sessionManager: SessionManager = {
        var sessionManager = SessionManager(configuration: .default)
        sessionManager.retrier = TokenRetrier()
        sessionManager.adapter = TokenAdapter()
        return sessionManager
    }()
    
    
    //  MARK: - Initializers
    
    //  Private init to force use of singleton
    private init() {}
}

extension AlamofireRequestHandler: RequestHandler {
    
    //  MARK: - Properties
    
    //  playPORTAL SSO tokens
    fileprivate (set) var accessToken: String? {
        get {
            return globalStorageManager.get("accessToken")
        }
        set {
            if let accessToken = newValue {
                globalStorageManager.set(accessToken, atKey: "accessToken")
            }
        }
    }
    
    fileprivate (set) var refreshToken: String? {
        get {
            return globalStorageManager.get("refreshToken")
        }
        set {
            if let refreshToken = newValue {
                globalStorageManager.set(refreshToken, atKey: "refreshToken")
            }
        }
    }
    
    //  User is authenticated if both `accessToken` and `refreshToken` aren't nil
    var isAuthenticated: Bool {
        return accessToken != nil && refreshToken != nil
    }
    
    
    //  MARK: - Methods
    
    /**
     Set SSO tokens.
    */
    @discardableResult
    func set(accessToken: String, andRefreshToken refreshToken: String) -> Bool {
        return globalStorageManager.set(accessToken, atKey: "accessToken")
            && globalStorageManager.set(refreshToken, atKey: "refreshToken")
    }
    
    /**
     Clear SSO tokens.
    */
    @discardableResult
    func clearTokens() -> Bool {
        return globalStorageManager.delete("accessToken") && globalStorageManager.delete("refreshToken")
    }
    
    /**
     Request data.
    */
    func request(_ request: URLRequestConvertible, _ completion: ((Error?, HTTPURLResponse?, Data?) -> Void)?) {
        guard let request = request.asURLRequest() else {
            completion?(PlayPortalError.API.failedToMakeRequest(message: "An error occurred while constructing the request."), nil, nil)
            return
        }
        AlamofireRequestHandler.sessionManager
            .request(request)
            .validate(statusCode: 200..<300)
            .response { response in
                completion?(response.error, response.response, response.data)
        }
    }
}


//  Class implementing Alamofire `RequestAdapter`
fileprivate class TokenAdapter {
    
}

extension TokenAdapter: RequestAdapter {
    
    //  Add access token to header for requests to playPORTAL apis
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        if let accessToken = AlamofireRequestHandler.shared.accessToken {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}


//  Class implementing Alamofire `RequestRetrier`
fileprivate class TokenRetrier {
    
    //  MARK: - Properties
    
    //  Lock when refreshing
    let lock = NSLock()
    
    //  Flag to indicate if a refresh is currently underway
    var isRefreshing = false
    
    //  Requests to retry once refresh has finished
    var requestsToRetry = [RequestRetryCompletion]()
}

extension TokenRetrier: RequestRetrier {
    
    //  Requests should be retried when there is a refresh error
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        //  Lock so refresh only occurs once
        lock.lock(); defer { lock.unlock() }
        
        requestsToRetry.append(completion)
        
        //  Refresh should only occur on refresh required error
        if let response = request.task?.response as? HTTPURLResponse
            , PlayPortalError.API.ErrorCode.errorCode(for: response) == .tokenRefreshRequired {
            if !isRefreshing {
                isRefreshing = true
                PlayPortalAuth.shared.refresh { [weak self] error, accessToken, refreshToken in
                    guard let strongSelf = self
                        , error == nil
                        , let accessToken = accessToken
                        , let refreshToken = refreshToken
                        else {
                            completion(false, 0.0)
                            return
                    }
                    strongSelf.lock.lock(); defer { strongSelf.lock.unlock() }
                    AlamofireRequestHandler.shared.accessToken = accessToken
                    AlamofireRequestHandler.shared.refreshToken = refreshToken
                    strongSelf.requestsToRetry.forEach { $0(true, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                    strongSelf.isRefreshing = false
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
}
