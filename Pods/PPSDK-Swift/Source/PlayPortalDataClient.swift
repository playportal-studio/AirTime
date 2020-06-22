//
//  PlayPortalDataClient.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation

class DataEndpoints: EndpointsBase {
  
  private static let base = DataEndpoints.host + "/app/v1"
  
  static let data = DataEndpoints.base + "/data"
  static let bucket = DataEndpoints.base + "/bucket"
  static let bucketList = DataEndpoints.base + "/bucket/list"
}

//  Responsible for making requests to playPORTAL app api
public final class PlayPortalDataClient: PlayPortalHTTPClient {
  
  public static let shared = PlayPortalDataClient()
  
  private override init() {}
  
  /**
   Read a user's private app data.
   - Parameter userId: User id for the owner of the app data to retrieve. A user can only query for his or her own app data of the app data of their kids' accounts.
   - Parameter completion: The closure invoked when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter data: The private app data returned for a successful request.
   */
  public func getPrivateAppData(
    userId: String? = nil,
    completion: @escaping (_ error: Error?, _ data: Any?) -> Void)
    -> Void
  {
    var params: [String: Any] = [:]
    if let userId = userId {
      params["userId"] = userId
    }
    
    request(
      url: DataEndpoints.data,
      method: .get,
      queryParameters: params,
      completionWithAnyResult: completion
    )
  }
  
  /**
   Update a user's private app data.
   - Parameter atKey: Location in app data to update, using dot object notation.
   - Parameter withValue: Value to insert or update at the location specified by the `key` parameter. This can be any valid JSON data.
   - Parameter userId: User id for the owner of the app data to update. A user can only update his or her own app data or the app data of their kids' accounts.
   - Parameter completion: The closure invoked when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter data: The updated data returned for a successful request.
   */
  public func updatePrivateAppData<V: Codable>(
    atKey key: String,
    withValue value: V,
    userId: String? = nil,
    _  completion: ((_ error: Error?, _ data: Any?) -> Void)?)
    -> Void
  {
    var val: Any? = value
    if let encoded = try? JSONEncoder().encode(["value": value]),
      let json = try? JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String: Any] {
      val = json?["value"]
    }
    
    var body: [String: Any?] = [
      "key": key,
      "value": val
    ]
    if let userId = userId {
      body["userId"] = userId
    }
    
    request(
      url: DataEndpoints.data,
      method: .post,
      body: body,
      completionWithAnyResult: completion
    )
  }
  
  /**
   Create a data bucket.
   - Parameter bucketName: Name given to the bucket.
   - Parameter includingUsers: Ids of users who will have access to the bucket; defaults to empty.
   - Parameter isPublic: Whether or not this bucket is public within your app space.
   - Parameter completion: The closure invoked when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Returns: Void
   */
  public func create(
    bucketNamed bucketName: String,
    includingUsers users: [String] = [],
    isPublic: Bool = false,
    _ completion: ((_ error: Error?) -> Void)?)
    -> Void
  {
    let body: [String: Any] = [
      "id": bucketName,
      "users": users,
      "public": isPublic
    ]
    
    request(
      url: DataEndpoints.bucket,
      method: .put,
      body: body,
      completionWithNoResult: { error in
        if let error = error as? PlayPortalError.API
          , case PlayPortalError.API.requestFailed(.alreadyExists, _) = error
        {
          completion?(nil)
        } else {
          completion?(error)
        }
    })
  }
  
  /**
   Write data to a bucket.
   - Parameter bucketNamed: The name of the bucket being written to.
   - Parameter atKey: At what key in the bucket the data will be written to. For nested keys, use a period-separated string eg. 'root.sub'.
   - Parameter withValue: The value being added to the bucket.
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter bucket: The bucket the data was added to returned for a successful request.
   - Returns: Void
   */
  public func update<V: Codable>(
    bucketNamed bucketName: String,
    atKey key: String,
    withValue value: V,
    _  completion: ((_ error: Error?, _ data: Any?) -> Void)?)
    -> Void
  {
    //  TODO: this code should probably be moved out of here
    var val: Any? = value
    if let encoded = try? JSONEncoder().encode(["value": value]),
      let json = try? JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String: Any] {
      val = json?["value"]
    }
    
    let body: [String: Any?] = [
      "id": bucketName,
      "key": key,
      "value": val
    ]
    
    let handleSuccess: HandleSuccess<Any> = { response, data in
      guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
        let data = json?["data"]
        else {
          throw PlayPortalError.API.unableToDeserializeResult(message: "Couldn't retrieve 'data' from result.")
      }
      return data
    }
    
    request(
      url: DataEndpoints.bucket,
      method: .post,
      body: body,
      handleSuccess: handleSuccess,
      completionWithAnyResult: completion
    )
  }
  
  /**
   Read data from a bucket.
   - Parameter bucketNamed: Name of the bucket being read from.
   - Parameter atKey: If provided, will read data from the bucket at this key, otherwise the entire bucket is returned;
   defaults to nil. For nested keys, use a period-separated string eg. 'root.sub'.
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter bucket: A `PlayPortalDataBucket` instance containing the data at `atKey` returned for a successful request.
   - Returns: Void
   */
  public func get(
    bucketNamed bucketName: String,
    atKey key: String? = nil,
    _ completion: @escaping (_ error: Error?, _ value: Any?) -> Void)
    -> Void
  {
    let params = [
      "id": bucketName,
      "key": key
    ]
    
    let handleSuccess: HandleSuccess<Any> = { response, data in
      guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
        let data = json?["data"]
        else {
          throw PlayPortalError.API.unableToDeserializeResult(message: "Couldn't retrieve 'data' from result.")
      }
      if let key = key,
        !key.isEmpty,
        let json = data as? [String: Any]
      {
        let keyPath = key.components(separatedBy: ".")
        return json.valueAtNestedKey(keyPath)!
      } else {
        return data
      }
    }
    
    request(
      url: DataEndpoints.bucket,
      method: .get,
      queryParameters: params,
      handleSuccess: handleSuccess,
      completionWithAnyResult: completion
    )
  }
  
  /**
   Read all buckets that the current user has access to.
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter buckets: An array of the names of the buckets the current user has access to.
   - Returns: Void
   */
  public func getAllBuckets(
    _ completion: @escaping (_ error: Error?, _ buckets: [String]?) -> Void)
    -> Void
  {
    request(
      url: DataEndpoints.bucketList,
      method: .get,
      completionWithDecodableResult: completion
    )
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
    get(bucketNamed: bucketName) { error, bucket in
      if let error = error {
        completion?(error, nil)
      } else if var bucket = bucket as? [String: Any] {
        bucket.removeValue(forKey: key)
        
        let body: [String: Any?] = [
          "id": bucketName,
          "key": "",
          "value": bucket
        ]
        
        let handleSuccess: HandleSuccess<Any> = { response, data in
          guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let data = json?["data"]
            else {
              throw PlayPortalError.API.unableToDeserializeResult(message: "Couldn't retrieve 'data' from result.")
          }
          return data
        }
        
        self.request(
          url: DataEndpoints.bucket,
          method: .post,
          body: body,
          handleSuccess: handleSuccess,
          completionWithAnyResult: completion
        )
      } else {
        completion?(PlayPortalError.API.requestFailedForUnknownReason(message: "Bucket was not of expected type."), nil)
      }
    }
  }
  
  /**
   Delete an entire bucket.
   - Parameter bucketNamed: The name of the bucket being deleted.
   - Parameter completion: The closure called when the request completes.
   - Parameter error: The error returned for an unsuccessful request.
   - Returns: Void
   */
  public func delete(
    bucketNamed bucketName: String,
    _ completion: ((_ error: Error?) -> Void)?)
    -> Void
  {
    let body = [
      "id": bucketName
    ]
    
    request(
      url: DataEndpoints.bucket,
      method: .delete,
      body: body,
      completionWithNoResult: completion
    )
  }
}
