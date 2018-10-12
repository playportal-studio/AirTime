//
//  PPDataService.swift
//  Helloworld-Swift-SDK
//
//  Created by Gary J. Baldwin on 9/15/18.
//  Copyright © 2018 Gary J. Baldwin. All rights reserved.
//

import Foundation

typealias PPDataCompletion = (_ succeeded: Bool, _ response: Any?, _ responseObject: Any?) -> Void
typealias PPDataReadCompletion = (_ succeeded: Bool, _ response: Any?, _ responseObject: [String:Any]?) -> Void

class PPDataService {
    // This class provides all user data services

    
    init() {}


    func openBucket(bucketName:String, users:[String], isPublic:Bool, completion: @escaping PPDataCompletion) {
        print("openBucket: \(bucketName) with users: \( users )" )
        
        PPManager.sharedInstance.PPwebapi.createBucket(bucketName: bucketName, users: users, isPublic:isPublic) { succeeded, response, responseObject in
            if(succeeded) {
                print("createBucket response: \(String(describing: response ))" )
                print("createBucket responseObject: \(String(describing: responseObject ))" )
                completion(true, response, responseObject)
            } else {
                completion(false, response, nil)
            }
        }
    }
    
    func readBucket(bucketName:String, key:String, completion: @escaping PPDataReadCompletion) {
        print("readBucket: \(bucketName) for key: \( key )" )
        PPManager.sharedInstance.PPwebapi.readBucket(bucketName: bucketName, key: key) { succeeded, response, responseObject in
            if(succeeded) {
                print("readBucket response: \(String(describing: response ))" )
                print("readBucket responseObject: \(String(describing: responseObject ))" )
                if let responseObject = responseObject {
                    let ro = responseObject as! [String: Any]
                    let d:Dictionary = (ro["data"] as? Dictionary<String, Any>)!
                    completion(true, response, d)
                    return
                }
            completion(false, response, nil)
        }
    }
 }
    func writeBucketKVstring(bucketName:String, key:String, value:String, completion: @escaping PPDataCompletion) {
        print("writeBucketKVstring: \(bucketName) for key: \( key ) with value: \( value )" )
        PPManager.sharedInstance.PPwebapi.writeBucketKVstring(bucketName: bucketName, key: key, value:value) { succeeded, response, responseObject in
            if(succeeded) {
                print("writeBucketKVstring response: \(String(describing: response ))" )
                print("writeBucketKVstring responseObject: \(String(describing: responseObject ))" )
                completion(true, response, responseObject)
            } else {
                completion(false, response, nil)
            }
        }
    }
    

    func writeBucketKVbool(bucketName:String, key:String, value:Bool, completion: @escaping PPDataCompletion) {
        print("writeBucketKVbool: \(bucketName) for key: \( key ) with value: \( value )" )
        PPManager.sharedInstance.PPwebapi.writeBucketKVbool(bucketName: bucketName, key: key, value:value) { succeeded, response, responseObject in
            if(succeeded) {
                print("writeBucketKVbool response: \(String(describing: response ))" )
                print("writeBucketKVbool responseObject: \(String(describing: responseObject ))" )
                completion(true, response, responseObject)
            } else {
                completion(false, response, nil)
            }
        }
    }
    
    func writeBucket(bucketName:String, key:String, value:Dictionary<String, Any>, completion: @escaping PPDataCompletion) {
        print("writeBucket: \(bucketName) for key: \( key ) with value: \( value )" )
        PPManager.sharedInstance.PPwebapi.writeBucket(bucketName: bucketName, key: key, value:value) { succeeded, response, responseObject in
            if(succeeded) {
                print("writeBucket response: \(String(describing: response ))" )
                print("writeBucket responseObject: \(String(describing: responseObject ))" )
                completion(true, response, responseObject)
            } else {
                completion(false, response, nil)
            }
        }
    }


func deleteFromBucket(bucketName:String, key:String, completion: @escaping PPDataCompletion) {
    print("deleteFromBucket: \(bucketName) for key: \( key )" )
        PPManager.sharedInstance.PPwebapi.deleteFromBucket(bucketName: bucketName, key: key) { succeeded, response, responseObject in
            if(succeeded) {
                print("deleteFromBucket response: \(String(describing: response ))" )
                print("deleteFromBucket responseObject: \(String(describing: responseObject ))" )
                completion(true, response, responseObject)
            } else {
                completion(false, response, nil)
            }
    }
}

func emptyBucket(bucketName:String, completion: @escaping PPDataCompletion) {
    completion(false, nil, nil)
}

}
