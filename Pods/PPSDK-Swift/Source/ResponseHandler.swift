//
//  ResponseHandler.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 11/8/18.
//

import Foundation

let globalResponseHandler = DefaultResponseHandler.shared

protocol ResponseHandler {
    
    func handleResponse<ResponseType: Codable>(
        _ error: Error?,
        _ response: HTTPURLResponse?,
        _ data: Data?,
        _ completion: ((Error?, ResponseType?) -> Void)?)
        -> Void
    
    func handleResponse<ResponseType: Codable>(
        _ error: Error?,
        _ response: HTTPURLResponse?,
        _ data: Data?,
        atKey key: String,
        _ completion: ((Error?, ResponseType?) -> Void)?)
        -> Void
}

extension ResponseHandler {
    
    func handleResponse<ResponseType: Codable>(
        _ error: Error?,
        _ response: HTTPURLResponse?,
        _ data: Data?,
        atKey key: String,
        _ completion: ((Error?, ResponseType?) -> Void)?)
        -> Void
    {
        let keys = key.split(separator: ".")
            .map { String($0) }
        let nestedValue = keys.dropLast()
            .reduce(data?.asJSON) { current, next in current?[next] as? [String: Any] }?[keys.last ?? ""]
        var data: Data?
        if let nestedValue = nestedValue {
            data = try? JSONSerialization.data(withJSONObject: nestedValue as Any, options: [])
        }
        handleResponse(error, response, data, completion)
    }
}

class DefaultResponseHandler: ResponseHandler {
    
    static let shared = DefaultResponseHandler()
    private init() {}
    
    func handleResponse<ResponseType: Codable>(
        _ error: Error?,
        _ response: HTTPURLResponse?,
        _ data: Data?,
        _ completion: ((Error?, ResponseType?) -> Void)?)
        -> Void
    {
        if let error = response.map({ PlayPortalError.API.createError(from: $0) }), error != nil {
            completion?(error, nil)
            return
        }
        let result: ResponseType? = { type in
            guard let data = data else { return nil }
            switch type {
            case is Data.Type:
                return data as? ResponseType
            default:
                return try? JSONDecoder().decode(ResponseType.self, from: data)
            }
        }(ResponseType.self)
        let err = result == nil ? PlayPortalError.API.unableToDeserializeResponse : nil
        completion?(err, result)
    }
}
