//
//  PlayPortalCollection.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 11/8/18.
//

import Foundation

public typealias CollectionType = Codable & Equatable

//  Responsible for 'collection' requests to playPORTAL data api
public final class PlayPortalCollection {
    
    public static let shared = PlayPortalCollection()
    private var requestHandler: RequestHandler = globalRequestHandler
    private var responseHandler: ResponseHandler = globalResponseHandler
    private var collections = CollectionContainer()
    
    private init() {}
    
    private func encode<C: CollectionType>(_ collection: [C]) -> [[String: Any]] {
        return collection.compactMap { $0.asDictionary }
    }
    
    private class CollectionContainer {
        
        private var collections = [String: [Any]]()
        private let queue = DispatchQueue(label: "com.dynepic.playPORTAL.collectionQueue", attributes: .concurrent)
        
        subscript(collectionName: String) -> [Any]? {
            get {
                var copy: [Any]?
                queue.sync {
                    copy = collections[collectionName]
                }
                return copy
            }
            set(newValue) {
                queue.async(flags: .barrier) { [unowned self] in
                    self.collections[collectionName] = newValue
                }
            }
        }
    }
    
    /**
     Create a collection.
     - Parameter collectionNamed: Name of the collection.
     - Parameter includingUsers: List of users that are able to view the collection; defaults to none.
     - Parameter public: Is the collection global; defaults to false.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Returns: Void
    */
    public func create(
        collectionNamed collectionName: String,
        includingUsers users: [String] = [],
        public isPublic: Bool = false,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        requestHandler.request(DataRouter.create(bucketName: collectionName, users: users, isPublic: isPublic)) {
            self.responseHandler.handleResponse($0, $1, $2) { (error, _: Data?) in
                if error == nil {
                    self.collections[collectionName] = []
                }
                completion?(error)
            }
        }
    }
    
    /**
     Read a collection.
     - Parameter fromCollection: The collection to be read.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: Error returned for an unsuccessful request.
     - Parameter collection: The collection returned for a successful request.
     - Returns: Void
    */
    public func read<C: CollectionType>(
        fromCollection collectionName: String,
        _ completion: @escaping (_ error: Error?, _ collection: [C]?) -> Void)
        -> Void
    {
        requestHandler.request(DataRouter.read(bucketName: collectionName, key: collectionName)) {
            self.responseHandler.handleResponse($0, $1, $2, atKey: "data.\(collectionName)") { (error, collection: [C]?) in
                if error == nil {
                    self.collections[collectionName] = collection
                }
                completion(error, collection)
            }
        }
    }
    
    /**
     Add element to a collection.
     - Parameter toCollection: Name of the collection.
     - Parameter element: The element being added.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter collection: The collection returned for a successful request.
     - Returns: Void
    */
    public func add<C: CollectionType>(
        toCollection collectionName: String,
        element: C,
        _ completion: @escaping (_ error: Error?, _ collection: [C]?) -> Void)
        -> Void
    {
        assert(collections[collectionName] != nil, "Cannot perform operations on a collection that hasn't been created.")
        assert(collections[collectionName] as? [C] != nil, "Elements in collection `\(collectionName)` do not match type \(type(of: C.self)).")
        
        let updatedCollection: [C] = collections[collectionName]! + [element] as! [C]
        requestHandler.request(DataRouter.write(bucketName: collectionName, key: collectionName, value: encode(updatedCollection))) {
            self.responseHandler.handleResponse($0, $1, $2, atKey: "data.\(collectionName)") { (error, collection: [C]?) in
                if error == nil {
                    self.collections[collectionName] = updatedCollection
                }
                completion(error, collection)
            }
        }
    }
    
    /**
     Remove element from collection.
     - Parameter fromCollection: The name of the collection being updated.
     - Paramter value: The element to be removed.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter collection: The collection returned for a successful request.
     - Returns: Void
    */
    public func remove<C: CollectionType>(
        fromCollection collectionName: String,
        value: C,
        _ completion: @escaping (_ error: Error?, _ collection: [C]?) -> Void)
        -> Void
    {
        assert(collections[collectionName] != nil, "Cannot perform operations on a collection that hasn't been created.")
        assert(collections[collectionName] as? [C] != nil, "Elements in collection `\(collectionName)` do not match type \(type(of: C.self)).")
        
        let updatedCollection = (collections[collectionName]! as! [C]).filter { $0 != value }
        requestHandler.request(DataRouter.write(bucketName: collectionName, key: collectionName, value: encode(updatedCollection))) {
            self.responseHandler.handleResponse($0, $1, $2, atKey: "data.\(collectionName)") { (error, collection: [C]?) in
                if error == nil {
                    self.collections[collectionName] = updatedCollection
                }
                completion(error, collection)
            }
        }
    }
    
    /**
     Update element in a collection.
     - Parameter inCollection: The collection being updated.
     - Parameter oldValue: The element being replaced.
     - Parameter newValue: The element being added.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter collection: The collection returned for a successful request.
     - Returns: Void
    */
    public func update<C: CollectionType>(
        inCollection collectionName: String,
        oldValue: C,
        newValue: C,
        _ completion: @escaping (_ error: Error?, _ collection: [C]?) -> Void)
        -> Void
    {
        assert(collections[collectionName] != nil, "Cannot perform operations on a collection that hasn't been created.")
        assert(collections[collectionName] as? [C] != nil, "Elements in collection `\(collectionName)` do not match type \(type(of: C.self)).")
        
        let updatedCollection = (collections[collectionName]! as! [C]).map { $0 == oldValue ? newValue: $0 }
        requestHandler.request(DataRouter.write(bucketName: collectionName, key: collectionName, value: encode(updatedCollection))) {
            self.responseHandler.handleResponse($0, $1, $2, atKey: "data.\(collectionName)") { (error, collection: [C]?) in
                if error == nil {
                    self.collections[collectionName] = updatedCollection
                }
                completion(error, collection)
            }
        }
    }
    
    /**
     Delete a collection.
     - Parameter collectionNamed: Name of the collection to be deleted.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Returns: Void
    */
    public func delete(
        collectionNamed collectionName: String,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        assert(collections[collectionName] != nil, "Cannot perform operations on a collection that hasn't been created.")
        requestHandler.request(DataRouter.delete(bucketName: collectionName)) {
            self.responseHandler.handleResponse($0, $1, $2) { (error, _ data: Data?) in
                if error == nil {
                    self.collections[collectionName] = nil
                }
                completion?(error)
            }
        }
    }
}
