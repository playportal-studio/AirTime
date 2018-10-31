//
//  callURL.swift
//  AirTime
//
//  Created by Joshua Paulsen on 9/10/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

public class Utils {
    static func openOrDownloadPlayPortal<T>(delegate: T) where T: SKStoreProductViewControllerDelegate, T: UIViewController {
        
        _ = SKStoreProductViewController()
        let playPortalURL = URL(string: "playportal://")!
        
        
        if UIApplication.shared.canOpenURL(playPortalURL) {
            UIApplication.shared.openURL(playPortalURL)
        }
        else {
            let vc = SKStoreProductViewController()
            let params = [
                SKStoreProductParameterITunesItemIdentifier: "com.dynepic.iOKids"
            ]
            vc.loadProduct(withParameters: params) { success, err in
                if err != nil {
                    
                }
            }
            vc.delegate = delegate
            delegate.present(vc, animated: true, completion: nil)
        }
    }
}
