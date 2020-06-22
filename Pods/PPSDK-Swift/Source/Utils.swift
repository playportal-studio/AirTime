//
//  Utils.swift
//
//  Created by Lincoln Fraley on 10/25/18.
//

import Foundation
import UIKit

//  Internal utilities class
class Utils {
  
  /**
   Get image asset from bundle by name.
   
   - Parameter byName: Name of the asset to get
   
   - Returns: UIImage of asset if found, nil otherwise.
   */
  static func getImageAsset(byName name: String) -> UIImage? {
    let frameworkBundle = Bundle(for: Utils.self)
    guard let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PPSDK-Swift-Assets.bundle")
      , let resourceBundle = Bundle(url: bundleURL)
      else {
        return nil
    }
    return UIImage(named: name, in: resourceBundle, compatibleWith: nil)
  }
}

class Synchronized<T> {
  
  private let queue = DispatchQueue(label: "com.dynepic.PPSDK-Swift.SynchronizedQueue-\(Int.random(in: 0..<Int.max))", attributes: .concurrent)
  private var _value: T
  public var value: T {
    get {
      var copy: T?
      queue.sync {
        copy = _value
      }
      return copy!
    }
    set(value) {
      queue.async(flags: .barrier) {
        self._value = value
      }
    }
  }
  
  init(value: T) {
    self._value = value
  }
}

extension Synchronized where T == Dictionary<AnyHashable, Any> {
  //
  //    subscript(index: T.Key) -> T.Value {
  //        get {
  //            return value[index]
  //        }
  //        set(newValue) {
  //
  //        }
  //    }
  
}
