//
//  KeychainWrapper.swift
//  Helloworld-Swift-SDK
//
//  Created by Gary J. Baldwin on 9/13/18.
//  Copyright © 2018 Gary J. Baldwin. All rights reserved.
//
// Trivial keychain getter/setter for reading/writing strings from/to iOS keychain.
// -- all access to this group of data in PlayPortalSDK "account" is via the singleton
//    PPManager so no thread safety protection is provided
//
//
import Foundation

class KeychainWrapper  {
    
    open func set(_ value: String, forKey key: String) -> Void {

        if let dvalue = value.data(using: String.Encoding.utf8) {
let anothervalue = "somestring"
        let query: [String : Any] = [
            kSecClass as String : kSecClassGenericPassword,
//            kSecAttrAccount as String : "PlayPortalSDK",
//            kSecValueRef as String   : dvalue
            kSecValueRef as String   : anothervalue.data(using: String.Encoding.utf8)
            ]

//        _ = SecItemAdd(query as CFDictionary, nil)
        let status = SecItemAdd(query as CFDictionary, nil)
//        print("KeychainWrapper set value: \(value ) for key: \(key ) and status: \(status )" )
        print("KeychainWrapper set value: \(anothervalue ) for key: \(key ) and status: \(status )" )
        return
        } else {
            print("KeychainWrapper dvalue conversion error: \(value ) for key: \(key )" )
            return
        }
    }
    
    open func get(_ key: String) -> String {
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
//            kSecAttrAccount as String : "PlayPortalSDK",
//            kSecMatchLimit as String : kSecMatchLimitOne,
            kSecReturnData as String : kCFBooleanTrue
        ]
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        

        print("KeychainWrapper get value: \(String(describing: result )) for key: \(key )  and status: \(status )" )
        
        if status == errSecSuccess {
            if let data = result as? Data {
                if let s = String(data: data as Data, encoding: .utf8) {
                        return s
                }
            }
        }
        return ""
    }
}
