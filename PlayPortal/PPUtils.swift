//
//  Utils.swift
//  Helloworld-Swift-SDK
//
//  Created by Gary J. Baldwin on 9/17/18.
//  Copyright © 2018 Gary J. Baldwin. All rights reserved.
//

import Foundation
import UIKit

func getCurrentViewController(_ vc: UIViewController) -> UIViewController? {
    if let pvc = vc.presentedViewController {
        return getCurrentViewController(pvc)
    }
    else if let svc = vc as? UISplitViewController, svc.viewControllers.count > 0 {
        return getCurrentViewController(svc.viewControllers.last!)
    }
    else if let nc = vc as? UINavigationController, nc.viewControllers.count > 0 {
        return getCurrentViewController(nc.topViewController!)
    }
    else if let tbc = vc as? UITabBarController {
        if let svc = tbc.selectedViewController {
            return getCurrentViewController(svc)
        }
    }
    return vc
}



/*
func findBestViewController(vc: UIViewController) -> UIViewController {
    if (vc.presentedViewController != nil) {
        // Return presented view controller
        return findBestViewController(vc: vc.presentedViewController)
    } else if vc.isKind(of: UISplitViewController class) {
        // Return right hand side
        let svc : UISplitViewController = vc as! UISplitViewController
        if (svc.viewControllers.count > 0) {
            return findBestViewController(vc: svc.viewControllers.lastObject)
        } else {
            return vc
        }
    } else if(vc.isKind(of: UINavigationController)) {
        // Return top view
        let svc:UINavigationController = vc as! UINavigationController
        if (svc.viewControllers.count > 0) {
            return [UIViewController findBestViewController:svc.topViewController];
        } else {
            return vc;
        }
    } else if vc.isKind(of: UITabBarController class) {
        // Return visible view
        let svc: UITabBarController = vc as UITabBarController
        if (svc.viewControllers.count > 0) {
            rturn [UIViewController findBestViewController:svc.selectedViewController];
        } else {
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

func currentViewController() -> UIViewController {
    //Find best view controller
    let viewController:UIViewController = UIApplication.shared.keyWindow.rootViewController
    return UIViewController.findBestViewController(viewController)
}

*/
