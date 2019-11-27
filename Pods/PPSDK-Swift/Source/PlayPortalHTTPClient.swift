//
//  PlayPortalHTTPClient.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 4/24/19.
//

import Foundation

typealias HTTPBody = [String: Any?]
typealias HTTPHeaderFields = [String: Any?]
typealias HTTPQueryParameters = [String: Any?]

typealias CreateRequest = (
  String,
  HTTPMethod,
  HTTPQueryParameters?,
  HTTPBody?,
  HTTPHeaderFields?
  ) -> URLRequest

typealias HandleFailure = (
  Error?,
  HTTPURLResponse
  ) -> Error

typealias HandleSuccess<Result> = (
  HTTPURLResponse,
  Data
  ) throws -> Result

class EndpointsBase {
  
  static let sandboxHost = "https://sandbox.playportal.io"
  static let productionHost = "https://api.playportal.io"
  static let developHost = "https://develop-api.goplayportal.com"
  
  static var host: String {
    switch (PlayPortalHTTPClient.environment) {
    case .sandbox:
      return sandboxHost
    case .develop:
      return developHost
    case .production:
      return productionHost
    }
  }
}

/**
 Class used internally by the SDK
 */
public class PlayPortalHTTPClient {
  
  
  //  MARK: - Properties
  
  static var environment = PlayPortalEnvironment.sandbox
  static var clientId = ""
  static var clientSecret = ""
  
  static var accessToken: String? {
    get { return globalStorageHandler.get("accessToken") }
    set(accessToken) {
      if let accessToken = accessToken {
        globalStorageHandler.set(accessToken, atKey: "accessToken")
      }
    }
  }
  
  static var refreshToken: String? {
    get { return globalStorageHandler.get("refreshToken") }
    set(refreshToken) {
      if let refreshToken = refreshToken {
        globalStorageHandler.set(refreshToken, atKey: "refreshToken")
      }
    }
  }
  
  static var isAuthenticated: Bool {
    return PlayPortalHTTPClient.accessToken != nil && PlayPortalHTTPClient.refreshToken != nil
  }
  
  
  static var isRefreshing = false
  static var requestsToRetry = [() -> Void]()
  static var lock = NSLock()
  
  func onEvent() {
    
  }
  
  //  Standard request creator
  //  Just takes params and creates a url request
  func defaultRequestCreator(
    url: String,
    method: HTTPMethod,
    queryParameters: HTTPQueryParameters? = nil,
    body: HTTPBody? = nil,
    headers: HTTPHeaderFields? = nil
    ) -> URLRequest
  {
    let _url = url
    guard var url = URL(string: url) else {
      fatalError("Couldn't create url from \(_url)")
    }
    
    if let queryParameters = queryParameters,
      var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
      components.queryItems = queryParameters
        .filter { $0.1 != nil }
        .map { URLQueryItem(name: $0.0, value: String(describing: $0.1!) ) }
      url = components.url!
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    if let body = body {
      request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
    }
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let headers = headers {
      for header in headers where header.value != nil {
        request.setValue(String(describing: header.value!), forHTTPHeaderField: header.key)
      }
    }
    
    return request
  }
  
  
  //  Creates an authenticated request using access token
  func standardAuthRequestCreator(accessToken: String?) -> CreateRequest {
    guard let accessToken = accessToken else {
      //  TODO: - should just logout
      fatalError("Attempting to make authenticatd request when not authenticated.")
    }
    return { url, method, queryParameters, body, headers -> URLRequest in
      var _headers = headers ?? [:]
      _headers["Authorization"] = "Bearer \(accessToken)"
      return self.defaultRequestCreator(url: url, method: method, queryParameters: queryParameters, body: body, headers: _headers)
    }
  }
  
  
  //  Standard failure handler
  //  Tries to create a PlayPortalError from response, otherwises returns a default error
  func defaultFailureHandler(
    error: Error?,
    response: HTTPURLResponse
    ) -> Error
  {
    return PlayPortalError.API.createError(from: response)
      ?? error
      ?? PlayPortalError.API.requestFailedForUnknownReason(message: "Request returned without response.")
  }
  
  
  //  Standard success handler
  //  Attempts to decode data to given Result type
  func defaultSuccessHandler<Result: Decodable>(
    response: HTTPURLResponse,
    data: Data
    ) throws -> Result
  {
    return try JSONDecoder().decode(Result.self, from: data)
  }

  func request(
    url: String,
    method: HTTPMethod,
    queryParameters: HTTPQueryParameters? = nil,
    body: HTTPBody? = nil,
    headers: HTTPHeaderFields? = nil,
    createRequest: CreateRequest? = nil,
    handleFailure: HandleFailure? = nil,
    handleSuccess: HandleSuccess<Any>? = nil,
    completionWithAnyResult: ((Error?, Any?) -> Void)?
    ) -> Void
  {
    //  TODO: - move all refresh code to RefreshClient
    
    PlayPortalHTTPClient.lock.lock(); defer { PlayPortalHTTPClient.lock.unlock() }
    
    let failureHandler = handleFailure ?? defaultFailureHandler
    let successHandler = handleSuccess ?? { response, data in try JSONSerialization.jsonObject(with: data, options: []) }
    
    //  If currently refreshing, just append the request to be made after refresh finishes
    if PlayPortalHTTPClient.isRefreshing {
      PlayPortalHTTPClient.requestsToRetry.append {
        
        self.request(
          url: url,
          method: method,
          queryParameters: queryParameters,
          body: body,
          headers: headers,
          createRequest: createRequest,
          handleFailure: failureHandler,
          handleSuccess: successHandler,
          completionWithAnyResult: completionWithAnyResult
        )
      }
    } else {
      
      let requestCreator = createRequest ?? standardAuthRequestCreator(accessToken: PlayPortalHTTPClient.accessToken)
      let urlRequest = requestCreator(url, method, queryParameters, body, headers)
      
      HTTPClient.perform(urlRequest) { error, response, data in
        
        //  If there is an error, or response code > 299, an error occurred
        if error != nil || (response?.statusCode != nil && response!.statusCode > 299) {
          guard let response = response else {
            completionWithAnyResult?(error, nil); return
          }
          
          //  If the response code matches tokenRefreshRequired, append request to be made after refresh finishes
          if PlayPortalError.API.ErrorCode.errorCode(for: response) == .tokenRefreshRequired {
            PlayPortalHTTPClient.lock.lock(); defer { PlayPortalHTTPClient.lock.unlock() }
            
            PlayPortalHTTPClient.requestsToRetry.append {
              
              self.request(
                url: url,
                method: method,
                queryParameters: queryParameters,
                body: body,
                headers: headers,
                createRequest: createRequest,
                handleFailure: failureHandler,
                handleSuccess: successHandler,
                completionWithAnyResult: completionWithAnyResult
              )
            }
            
            //  If not currently refreshing, start refresh
            if !PlayPortalHTTPClient.isRefreshing {
              PlayPortalHTTPClient.isRefreshing = true
              RefreshClient.shared.refresh()
            }
            
            //  Some other error that doesn't need to be handled by sdk and is passed back to user
          } else {
            completionWithAnyResult?(failureHandler(error, response), nil)
          }
          
          
        } else {
          
          //  Hopefully we should always get a response and data back...
          guard let response = response, let data = data else {
            completionWithAnyResult?(PlayPortalError.API.requestFailedForUnknownReason(message: "Request returned without response."), nil); return
          }
          
          //  If deserializing response/data is a success, request successful, otherwise failed
          do {
            completionWithAnyResult?(nil, try successHandler(response, data))
          } catch {
            completionWithAnyResult?(error, nil)
          }
        }
      }
    }
  }
  
  func request(
    url: String,
    method: HTTPMethod,
    queryParameters: HTTPQueryParameters? = nil,
    body: HTTPBody? = nil,
    headers: HTTPHeaderFields? = nil,
    createRequest: CreateRequest? = nil,
    handleFailure: HandleFailure? = nil,
    handleSuccess: HandleSuccess<Data>? = nil,
    completionWithNoResult: ((Error?) -> Void)?
    ) -> Void
  {
    request(
      url: url,
      method: method,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      createRequest: createRequest,
      handleFailure: handleFailure,
      handleSuccess: handleSuccess,
      completionWithAnyResult: { error, _ in completionWithNoResult?(error) }
    )
  }
  
  func request<Result: Decodable>(
    url: String,
    method: HTTPMethod,
    queryParameters: HTTPQueryParameters? = nil,
    body: HTTPBody? = nil,
    headers: HTTPHeaderFields? = nil,
    createRequest: CreateRequest? = nil,
    handleFailure: HandleFailure? = nil,
    handleSuccess: HandleSuccess<Result>? = nil,
    completionWithDecodableResult: ((Error?, Result?) -> Void)?
    ) -> Void
  {
    request(
      url: url,
      method: method,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      createRequest: createRequest,
      handleFailure: handleFailure,
      handleSuccess: handleSuccess ?? { response, data in try JSONDecoder().decode(Result.self, from: data) },
      completionWithAnyResult: { error, result in completionWithDecodableResult?(error, result as? Result) }
    )
  }
}
