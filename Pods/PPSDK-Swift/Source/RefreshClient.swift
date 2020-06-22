//
//  RefreshClient.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 4/25/19.
//

import Foundation

class RefreshClient: PlayPortalHTTPClient {
  
  static let shared = RefreshClient()
  
  
  private override init() {}
  
  
  func refresh() {
    
    guard let accessToken = RefreshClient.accessToken,
      let refreshToken = RefreshClient.refreshToken else {
        //  TODO: - should just logout
        fatalError("Attempting to refresh when not authenticated.")
    }
    
    let queryParameters: [String: Any] = [
      "access_token": accessToken,
      "refresh_token": refreshToken,
      "client_id": RefreshClient.clientId,
      "client_secret": RefreshClient.clientSecret,
      "grant_type": "refresh_token"
    ]
    
    let request = defaultRequestCreator(url: AuthEndpoints.token, method: .post, queryParameters: queryParameters)
    
    HTTPClient.perform(request) { error, _, data in
      
      guard error == nil else {
        
        //  TODO - change this
        EventHandler.shared.publish(.loggedOut(error: error)); return
      }
      
      guard let data = data,
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
        let accessToken = json?["access_token"] as? String,
        let refreshToken = json?["refresh_token"] as? String
        else {
          
          //  TODO - change this
          EventHandler.shared.publish(.loggedOut(error: PlayPortalError.API.unableToDeserializeResult(message: "Couldn't parse access or refresh token from refresh response."))); return
      }
      
      RefreshClient.lock.lock()
      
      RefreshClient.accessToken = accessToken
      RefreshClient.refreshToken = refreshToken
      RefreshClient.isRefreshing = false
      let requestsToRetry = PlayPortalHTTPClient.requestsToRetry
      RefreshClient.requestsToRetry.removeAll()
      
      RefreshClient.lock.unlock()
      requestsToRetry.forEach { $0() }
    }
  }
}
