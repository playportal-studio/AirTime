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
        
        let font = UIFont(name: "Still Time", size: 25.0)!
        let textAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName:UIColor.airtimeColors.yellow
        ]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        UINavigationBar.appearance().barTintColor = UIColor.airtimeColors.lightGrey
        UINavigationBar.appearance().tintColor = UIColor.white
        
        return true
    }
    
}

