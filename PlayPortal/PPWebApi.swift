//
//  PPWebApi.swift
//  Helloworld-Swift-SDK
//
//  Created by Gary J. Baldwin on 9/15/18.
//  Copyright © 2018 Gary J. Baldwin. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

/*
class AccessTokenAdapter: RequestAdapter {
    private var accessToken: String
    
    init(accessToken: String) { self.accessToken = accessToken  }
    func update(accessToken: String) { self.accessToken = accessToken }
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, !urlString.contains("oauth") { //  hasPrefix("https://httpbin.org") {
            urlRequest.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
            print("AccessTokenAdapter - after adding auth header urlRequest: \(urlRequest )")
            return urlRequest
        }
        return urlRequest
    }
}
*/


class OAuth2Handler: RequestAdapter, RequestRetrier {
//    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    private var clientID: String
    private var clientSecret: String
    private var baseURLString: String
    private var accessToken: String
    private var refreshToken: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    public init(clientID: String, clientSecret: String, baseURLString: String, accessToken: String, refreshToken: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.baseURLString = baseURLString
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func updateTokens(accessToken: String, refreshToken: String) -> Void {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    // Adapter calls
    func update(accessToken: String) { self.accessToken = accessToken }
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, !urlString.contains("oauth") { //  hasPrefix("https://httpbin.org") {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshAccessTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
    func refreshAccessTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true

        let urlString = "\(baseURLString)/oauth/token"
        
        let parameters: [String: Any] = [
            "access_token": accessToken,
            "refresh_token": refreshToken,
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": "refresh_token"
        ]
        
        sessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                
                print("refreshAccessTokens response: \(response )")

                if
                    let json = response.result.value as? [String: Any],
                    let accessToken = json["access_token"] as? String,
                    let refreshToken = json["refresh_token"] as? String
                {
                    self?.update(accessToken:accessToken)
                    completion(true, accessToken, refreshToken)
                } else {
                    completion(false, nil, nil)
                }
                
                strongSelf.isRefreshing = false
        }
    }
}




//typealias PPWebApiCompletion = (_ succeeded: Bool, _ response: Any?, _ responseObject: [AnyHashable:Any]?) -> Void
typealias PPWebApiCompletion = (_ succeeded: Bool, _ response: Any?, _ responseObject: Any?) -> Void


class PPWebApi {
    // _PPWebApi is an internally visible class that provides API services to the playPORTAL SDK
//    typealias PPWebApiCompletion = (_ succeeded: Bool, _ response: Any?, _ responseObject: [AnyHashable:Any]?) -> Void

//    let accessTokenAdapter: AccessTokenAdapter
    let oauthHandler: OAuth2Handler
    var cid, cse, baseUrl, at, rt:String
    var apiOauthBase: String
    let kc:KeychainSwift
    let sessionManager: SessionManager
    
    public init(clientId: String, clientSecret: String, baseURLString: String, accessToken: String, refreshToken: String, keychain:KeychainSwift) {
        print("PPWebApi init clientId: \(clientId ), accessToken: \( accessToken ) , refreshToken: \( refreshToken )" )
        cid = clientId
        cse = clientSecret
        baseUrl = baseURLString
        at = accessToken
        rt = refreshToken

        apiOauthBase = "\(baseUrl)/\("oauth")"
        oauthHandler = OAuth2Handler(clientID: cid, clientSecret: cse, baseURLString: baseUrl, accessToken: at, refreshToken: rt)

        sessionManager = SessionManager()
        sessionManager.adapter = oauthHandler
        sessionManager.retrier = oauthHandler
//        accessTokenAdapter = AccessTokenAdapter(accessToken: at)
//        sessionManager.adapter = accessTokenAdapter

        kc = keychain
    }
    
    func hydrateTokens(accessToken:String, refreshToken:String) -> Void {
        self.at = accessToken
        self.rt = refreshToken
        oauthHandler.updateTokens(accessToken: accessToken, refreshToken: refreshToken)
//        accessTokenAdapter.update(accessToken: accessToken)
    }
    
    // All API methods go here
    func getUserProfile(completion: @escaping PPWebApiCompletion ) {
        let urlString = baseUrl +  "/user/v1/my/profile"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + self.at,
            "Accept": "application/json"
        ]
//        sessionManager.request(urlString).responseJSON { (response: DataResponse<Any>) in
        sessionManager.request(urlString, headers: headers).validate(statusCode: 200..<300).responseJSON { (response: DataResponse<Any>) in
            print("Request: \(String(describing: request))")   // original url request
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(String(describing: response.result.value))")   // response serialization result

            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                    completion(true, response, json)
                } else {
                    completion(false, nil, nil)
                }
            case .failure(let error):
                print(error)
                completion(false, nil, nil)
            }
        }
    }

    
    func getProfileOrCoverImage(isProfile:Bool, completion: @escaping PPWebApiCompletion ) {
        var tag = "cover"
        if(isProfile) { tag = "picture" }
        let urlString = baseUrl + "/user/v1/my/profile/" + tag

        sessionManager.request(urlString).responseData { response in
            print("Request: \(String(describing: request))")   // original url request
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(String(describing: response.result.value))")   // response serialization result

            if let data = response.result.value {
                let image = UIImage(data: data)
                completion(true, response, image)
            } else {
                completion(false, response, nil)
            }
        }
    }
    

    func getImage(id: String, completion: @escaping PPWebApiCompletion ) {
     }
 
    
    func getFriendsProfiles(completion: @escaping PPWebApiCompletion ) {
        let urlString = baseUrl +  "/user/v1/my/friends"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + self.at,
            "Accept": "application/json"
        ]
        sessionManager.request(urlString, headers: headers).validate(statusCode: 200..<300).responseJSON { response  in
            print("Request: \(String(describing: request))")   // original url request
            print("\nResponse.request: \(String(describing: response.request))")   // original url request
            print("\nResponse.result: \(String(describing: response.result))") // http url response
            print("\nResponse.result.value: \(String(describing: response.result.value))")   // response serialization result
            
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    completion(true, response, json)
                } else {
                    completion(false, nil, nil)
                }
            case .failure(let error):
                print(error)
                completion(false, nil, nil)
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    // Data API
    // -----------------------------------------------------------------------------
    func createBucket(bucketName:String, users: [String], isPublic:Bool, completion: @escaping PPWebApiCompletion ) {
        let urlString = baseUrl +  "/app/v1/bucket"
        let url = URL(string: urlString)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "PUT"
        
        let parameters = ["id": bucketName, "users": users, "public": isPublic] as [String : Any]
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + self.at, forHTTPHeaderField: "Authorization")
        
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).responseJSON { response  in
            print("Request: \(String(describing: urlRequest))")   // original url request
            print("\nResponse.request: \(String(describing: response.request))")   // original url request
            print("\nResponse.result: \(String(describing: response.result))") // http url response
            print("\nResponse.result.value: \(String(describing: response.result.value))")   // response serialization result
            
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                    completion(true, response, json)
                } else {
                    completion(false, nil, nil)
                }
            case .failure(let error):
                print("createBucket error: \( error )" )
                if response.response?.statusCode == 409 {
                    completion(true, response, response.result.value)
                } else {
                    completion(false, nil, nil)
                }
            }
        }
    }
    
    // Upserts a single KV pair, where V is a String
    func writeBucketKVstring(bucketName: String, key:String, value:String, completion: @escaping PPWebApiCompletion ) {
        let urlString = baseUrl +  "/app/v1/bucket"
        let url = URL(string: urlString)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        let parameters = ["id": bucketName, "key": key, "value": value] as [String : Any]
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + self.at, forHTTPHeaderField: "Authorization")
        
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).responseJSON { response  in
            switch response.result {
            case .success:
                completion(true, response, response.value)
            case .failure(let error):
                print("writeBucket error: \( error )" )
                completion(false, nil, nil)
            }
        }
    }
    
    func writeBucketKVbool(bucketName: String, key:String, value:Bool, completion: @escaping PPWebApiCompletion ) {
        let urlString = baseUrl +  "/app/v1/bucket"
        let url = URL(string: urlString)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        let parameters = ["id": bucketName, "key": key, "value": value] as [String : Any]
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + self.at, forHTTPHeaderField: "Authorization")
        
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).responseJSON { response  in
            switch response.result {
            case .success:
                completion(true, response, response.value)
            case .failure(let error):
                print("writeBucket error: \( error )" )
                completion(false, nil, nil)
            }
        }
    }
    
        // Upserts a KV pair where V is a dictionary
    func writeBucket(bucketName: String, key:String, value:Dictionary<String, Any>, completion: @escaping PPWebApiCompletion ) {
        let urlString = baseUrl +  "/app/v1/bucket"
        let url = URL(string: urlString)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        let parameters = ["id": bucketName, "key": key, "value": value] as [String : Any]
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + self.at, forHTTPHeaderField: "Authorization")
        
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).responseJSON { response  in
            switch response.result {
            case .success:
                    completion(true, response, response.value)
            case .failure(let error):
                print("writeBucket error: \( error )" )
                completion(false, nil, nil)
            }
        }
    }
    

     // Read either the entire bucket (if Key=nil) - Returns a dictionary containing a data object (that can contain unspecified structure)
    // Read a single KV pair - Returns a dictionary containing a single pair  Ex: d = { thekey:thevalue };
    func readBucket(bucketName:String, key:String, completion: @escaping PPWebApiCompletion ) {
        print("readBucket from bucket %@", bucketName)
        let urlString = baseUrl + "/app/v1/bucket" + "?id=" + bucketName + "&key=" +  key
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + self.at,
            "Accept": "application/json"
        ]

        sessionManager.request(urlString, headers: headers).validate(statusCode: 200..<300).responseJSON { response  in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    completion(true, response, json)
                } else {
                    completion(false, nil, nil)
                }
            case .failure(let error):
                print(error)
                completion(false, nil, nil)
            }
        }
    }

    func  deleteFromBucket(bucketName: String, key: String, completion: @escaping PPWebApiCompletion) {
        print("deleteFromBucket from bucket: \( bucketName ) and key: \( key )" )
        writeBucket(bucketName:bucketName, key:key, value: [:]) { succeeded, response, responseObject in
            completion(succeeded, response, responseObject)
        }
    }
    
    func  emptyBucket(bucketName: String, completion: @escaping PPWebApiCompletion) {
        print("Empty Bucket is not implemented!")
        completion(true, nil, nil)
    }
} // end class
