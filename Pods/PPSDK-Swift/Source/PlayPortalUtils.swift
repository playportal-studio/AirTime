//
//  PlayPortalUtils.swift
//
//  Created by Lincoln Fraley on 10/31/18.
//

import Foundation
import UIKit
import StoreKit

//  Publicly available utility functions
public final class PlayPortalUtils: NSObject {
  
  private static let shared = PlayPortalUtils()
  private override init() {}
  
  
  //  MARK: - Methods
  
  /**
   Opens playPORTAl on user's phone if downloaded or opens app store for user to download it.
   
   - Parameter from: The view controller to open `SKStoreProductViewController` from; defaults to top most view controller.
   
   - Returns: Void
   */
  public static func openOrDownloadPlayPORTAL(from: UIViewController? = nil) -> Void {
    
    //  Attempt to open playPORTAL
    if let playPortalURL = URL(string: "playportal://") , UIApplication.shared.canOpenURL(playPortalURL) {
      UIApplication.shared.open(playPortalURL, options: [:], completionHandler: nil)
    } else {
      //  Otherwise, open playPORTAL through StoreKit
      let storeProductVC = SKStoreProductViewController()
      storeProductVC.delegate = PlayPortalUtils.shared
      
      let params = [
        SKStoreProductParameterITunesItemIdentifier: "1112657594"
      ]
      storeProductVC.loadProduct(withParameters: params) { _, error in
        if error != nil {
          storeProductVC.dismiss(animated: true, completion: nil)
        }
      }
      
      let openFrom = from ?? UIApplication.topMostViewController()
      openFrom?.present(storeProductVC, animated: true, completion: nil)
    }
  }
}


//  Add conformance to dismiss `SKStoreProductViewController`
extension PlayPortalUtils: SKStoreProductViewControllerDelegate {
  
  @objc public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }
}
