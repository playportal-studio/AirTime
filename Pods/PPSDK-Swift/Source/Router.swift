//
//  Router.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 11/8/18.
//

import Foundation

//  Protocol that requires a conforming type to be convertible to `URLRequest`
protocol URLRequestConvertible {
    func asURLRequest() -> URLRequest
}

//  Enum that conforms to `URLRequestConvertible`
//  Contains cases for possible HTTP methods
enum Router: URLRequestConvertible {
    
    case get(url: String, params: [String: Any?]?)
    case put(url: String, body: [String: Any?]?, params: [String: Any?]?)
    case post(url: String, body: [String: Any?]?, params: [String: Any?]?)
    case delete(url: String, body: [String: Any?]?, params: [String: Any?]?)
    
    func asURLRequest() -> URLRequest {
        var (method, url, body, params): (String, URL, [String: Any?]?, [String: Any?]?) = {
            switch self {
            case let .get(url, params):
                return ("GET", URL(string: url)!, nil, params)
            case let .put(url, body, params):
                return ("PUT", URL(string: url)!, body, params)
            case let .post(url, body, params):
                return ("POST", URL(string: url)!, body, params)
            case let .delete(url, body, params):
                return ("DELETE", URL(string: url)!, body, params)
            }
        }()
        
        if let params = params, var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            components.queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1 as? String) }
            url = try! components.asURL()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        if let body = body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
        }
        
        return urlRequest
    }
}
