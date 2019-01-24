//
//  StorageManager.swift
//
//  Created by Lincoln Fraley on 10/26/18.
//

import Foundation
import KeychainSwift

let globalStorageManager: StorageManager = KeychainSwift()

//  Protocol to be implemented by class responsible for secure storage
protocol StorageManager {
    
    //  MARK: - Methods
    
    /**
     Store value at key.
     
     - Parameter value: Value being stored.
     - Parameter atKey: Key the value is being stored at.
     
     - Returns: True if the value was successfully stored.
    */
    @discardableResult
    func set(_ value: String, atKey key: String) -> Bool
    
    /**
     Get value at key.
     
     - Parameter key: Key at which to get value.
     
     - Returns: Value if successful, nil otherwise.
    */
    func get(_ key: String) -> String?
    
    /**
     Delete a key.
     
     - Paramter key: The key to be deleted.
     
     - Returns: True if key was successfully deleted.
    */
    @discardableResult
    func delete(_ key: String) -> Bool
    
    /**
     Clear all keys.
     
     - Returns: True if all keys were successfully cleared.
    */
    @discardableResult
    func clear() -> Bool
}
