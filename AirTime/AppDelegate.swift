//
//  AppDelegate.swift
//  AirTime
//
//  Created by Jett Black on 9/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit
import KontaktSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Kontakt.setAPIKey("QvFXHcKgdPGpsWOsCOvTfwIFgBRVOwXv")
                
        return true
    }
    
}

