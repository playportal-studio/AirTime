//
//  CustomFunctions.swift
//  AirTime
//
//  Created by Joshua Paulsen on 1/17/19.
//  Copyright © 2019 Dynepic, Inc. All rights reserved.
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
