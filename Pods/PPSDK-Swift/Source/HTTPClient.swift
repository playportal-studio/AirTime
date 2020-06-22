//
//  HTTPClient.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 4/24/19.
//

import Foundation

enum HTTPMethod: String {
  
  case get = "GET"
  case put = "PUT"
  case post = "POST"
  case delete = "DELETE"
}

enum HTTPClientError: Error {
  
  case incorrectResponseType
}

class HTTPClient {
  
  static func perform(
    _ request: URLRequest,
    _ completion: @escaping (_ error: Error?, _ response: HTTPURLResponse?, _ data: Data?) -> Void
    ) -> Void
  {
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let response = response as? HTTPURLResponse else {
        completion(HTTPClientError.incorrectResponseType, nil, nil); return
      }
      completion(error, response, data)
    }
    
    task.resume()
    
  }
}
