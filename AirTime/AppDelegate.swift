//
//  AppDelegate.swift
//  Developer Samples
//
//  Created by Szymon Bobowiec on 12.12.2016.
//  Copyright © 2016 kontakt.io. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let font = UIFont(name: "Still Time", size: 22.0)!
        let attributes = [NSFontAttributeName: font]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        return true
    }
    
}

