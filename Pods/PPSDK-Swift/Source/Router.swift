//
//  Router.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 11/8/18.
//

import Foundation

//  Protocol that requires a conforming type to be convertible to `URLRequest`
protocol URLRequestConvertible {
    func asURLRequest() -> URLRequest?
}

//  Enum that conforms to `URLRequestConvertible`
//  Contains cases for possible HTTP methods
enum Router: URLRequestConvertible {
    
    case get(url: String, params: [String: String?]?)
    case put(url: String, body: [String: Any?]?, params: [String: String?]?)
    case post(url: String, body: [String: Any?]?, params: [String: String?]?)
    case delete(url: String, body: [String: Any?]?, params: [String: String?]?)
    
    func asURLRequest() -> URLRequest? {
        let method: String = {
            switch self {
            case .get:
                return "GET"
            case .put:
                return "PUT"
            case .post:
                return "POST"
            case .delete:
                return "DELETE"
            }
        }()
        
        let body: [String: Any?]? = {
            switch self {
            case .put(_, let body, _), .post(_, let body, _), .delete(_, let body, _):
                return body
            default:
                return nil
            }
        }()
        
        let params: [String: String?]? = {
            switch self {
            case .get(_, let params), .put(_, _, let params), .post(_, _, let params), .delete(_, _, let params):
                return params
            }
        }()
        
        var _url: URL? = {
            var path: String
            switch self {
            case .get(let url, _), .put(let url, _, _), .post(let url, _, _), .delete(let url, _, _):
                path = url
            }
            return URL(string: path)
        }()
        
        if let params = params, let url = _url, var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            var queryItems = [URLQueryItem]()
            for (name, value) in params {
                queryItems.append(URLQueryItem(name: name, value: value))
            }
            components.queryItems = queryItems
            _url =  try? components.asURL()
        }
        
        guard let url = _url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        if let body = body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
        }
        
        return urlRequest
    }
}
