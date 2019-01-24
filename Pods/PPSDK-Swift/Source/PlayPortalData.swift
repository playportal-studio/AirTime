//
//  PlayPortalData.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation

//  Available routes for playPORTAL data api
enum DataRouter: URLRequestConvertible {
    
    case create(bucketName: String, users: [String], isPublic: Bool)
    case write(bucketName: String, key: String, value: Any?)
    case read(bucketName: String, key: String?)
    case delete(bucketName: String)
    
    func asURLRequest() -> URLRequest? {
        switch self {
        case let .create(bucketName, users, isPublic):
            let body: [String: Any] = [
                "id": bucketName,
                "users": users,
                "public": isPublic
            ]
            return Router.put(url: URLs.App.bucket, body: body, params: nil).asURLRequest()
        case let .write(bucketName, key, value):
            let body: [String: Any?] = [
                "id": bucketName,
                "key": key,
                "value": value
            ]
            return Router.post(url: URLs.App.bucket, body: body, params: nil).asURLRequest()
        case let .read(bucketName, key):
            let params = [
                "id": bucketName,
                "key": key
            ]
            return Router.get(url: URLs.App.bucket, params: params).asURLRequest()
        case let .delete(bucketName):
            let body = [
                "id": bucketName
            ]
            return Router.delete(url: URLs.App.bucket, body: body, params: nil).asURLRequest()
        }
    }
}

//  Responsible for making requests to playPORTAL app api
public final class PlayPortalData {

    public static let shared = PlayPortalData()
    private let requestHandler: RequestHandler = globalRequestHandler
    private let responseHandler: ResponseHandler = globalResponseHandler
    
    private init() {}
    
    /**
     Create a data bucket.
     - Parameter bucketName: Name given to the bucket.
     - Parameter includingUsers: Ids of users who will have access to the bucket; defaults to empty.
     - Parameter isPublic: Indicates if the bucket is globally available; defaults to false.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Returns: Void
    */
    public func create(
        buckedNamed bucketName: String,
        includingUsers users: [String] = [],
        isPublic: Bool = false,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        requestHandler.request(DataRouter.create(bucketName: bucketName, users: users, isPublic: isPublic)) {
            self.responseHandler.handleResponse($0, $1, $2) { (error, _ data: Data?) in completion?(error) }
        }
    }
    
    /**
     Write data to a bucket.
     - Parameter toBucket: The name of the bucket being written to.
     - Parameter atKey: At what key in the bucket the data will be written to. For nested keys, use a period-separated string eg. 'root.sub'.
     - Parameter withValue: The value being added to the bucket.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter bucket: The bucket the data was added to returned for a successful request.
     - Returns: Void
    */
    public func write<V: Codable>(
        toBucket bucketName: String,
        atKey key: String,
        withValue value: V,
        _  completion: ((_ error: Error?, _ data: Any?) -> Void)?)
        -> Void
    {
        var val: Any?
        if let encoded = try? JSONEncoder().encode(["value": value]), let json = try? JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String: Any] {
            val = json?["value"]
        }
        requestHandler.request(DataRouter.write(bucketName: bucketName, key: key, value: val)) { error, response, data in
            guard error == nil
                , let data = data?.asJSON?.valueAtNestedKey("data.\(key)")
                else {
                    completion?(error, nil)
                    return
            }
            completion?(error, data)
        }
    }
    
    /**
     Read data from a bucket.
     
     - Parameter fromBucket: Name of the bucket being read from.
     - Parameter atKey: If provided, will read data from the bucket at this key, otherwise the entire bucket is returned;
        defaults to nil. For nested keys, use a period-separated string eg. 'root.sub'.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter bucket: A `PlayPortalDataBucket` instance containing the data at `atKey` returned for a successful request.
     
     - Returns: Void
    */
    public func read(
        fromBucket bucketName: String,
        atKey key: String? = nil,
        _ completion: @escaping (_ error: Error?, _ value: Any?) -> Void)
        -> Void
    {
        requestHandler.request(DataRouter.read(bucketName: bucketName, key: key)) { error, _, data in
            guard error == nil
                , let json = data?.asJSON
                , let d = json["data"] as? [String: Any]
                , let value = key != nil ? d[key!] : d
                else {
                    completion(error, nil)
                    return
            }
            completion(error, value)
        }
    }
    
    /**
     Delete data from a bucket.
     
     - Parameter fromBucket: Name of the bucket where data is being deleted from.
     - Parameter atKey: At what key to delete data.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter bucket: The updated bucket returned for a successful request.
     
     - Returns: Void
    */
    public func delete(
        fromBucket bucketName: String,
        atKey key: String,
        _ completion: ((_ error: Error?, _ bucket: Any?) -> Void)?)
        -> Void
    {
        requestHandler.request(DataRouter.write(bucketName: bucketName, key: key, value: nil)) { error, response, data in
            if let e = response.map({ PlayPortalError.API.createError(from: $0) }), e != nil {
                print(e)
                print()
            }
            guard error == nil
                , let value = data?.asJSON?["data"]
                else {
                    completion?(error, nil)
                    return
            }
            completion?(error, value)
        }
    }
    
    /**
     Delete an entire bucket.
     
     - Parameter bucketNamed: The name of the bucket being deleted.
     - Parameter completion: The closure called when the request completes.
     - Parameter error: The error returned for an unsuccessful request.
     
     - Returns: Void
    */
    public func delete(bucketNamed bucketName: String, _ completion: ((_ error: Error?) -> Void)?) -> Void {
//        requestHandler.request(DataRouter.delete(bucketName: bucketName)) { error, _ in completion?(error) }
    }
    
    // createBucket
    
    //  readBucketJSON
    
    //  readBucketDecodable
    
    //  writeBucketJSON
    
    //  writeBucketDecodable
    
    //  deleteFromBucketJSON
    
    //  deleteFromBucketDecodable
    
    //  deleteBucket
}
