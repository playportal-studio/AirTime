//
//  KeychainStorageManager.swift
//
//  Created by Lincoln Fraley on 10/26/18.
//

import Foundation
import KeychainSwift

//  Add conformance for `KeychainSwift` to `StorageManager`
extension KeychainSwift: StorageManager {
    
    func set(_ value: String, atKey key: String) -> Bool {
        return set(value, forKey: key)
    }
}
