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
