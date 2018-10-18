//
//  AppDelegate.swift
//  Developer Samples
//
//  Created by Gary Baldwin on Oct 1, 2018.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let cid = "iok-cid-016bdbdafeaec0d094546e5c989c1e28c34810ea4e6b5922"
    let cse = "iok-cse-bfe928f92578946eae8d7011d4023ca339aa4acc3eaf2fd6"
    let redirectURI = "airtime://redirect"
    let env = "SANDBOX"
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //  Configure with your credentials, environment and redirect uri
        PPManager.sharedInstance.configure(env: env, clientId: cid, secret: cse, andRedirectURI: redirectURI)
        
        
        PPManager.sharedInstance.addUserListener { user, authenticated in
            print("userListener invoked authd: \( authenticated )  user: \(String(describing:  user ))" )
            
            let sb:UIStoryboard = UIStoryboard.init(name:"Main", bundle:nil)
            guard let rvc:UIViewController = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            
            if (!authenticated) {
                let vc:LoginViewController = sb.instantiateViewController(withIdentifier:"LoginViewController") as! LoginViewController
                vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal;
                if let cvc = getCurrentViewController(rvc) {
                    print("userListener NOT authd current VC: \(cvc )" );
                    cvc.present(vc, animated:true, completion:nil)
                }
            } else {
                let hvc:HomeViewController = sb.instantiateViewController(withIdentifier: "Air Time Scene") as! HomeViewController
                if let u = user {
                    hvc.user = u
                }
                hvc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal;
                if let cvc = getCurrentViewController(rvc) {
                    print("userListener authd current VC: \(cvc )" );
                    cvc.present(hvc, animated:true, completion:nil)
                }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        PPManager.sharedInstance.handleOpenURL(url:url)
        return true
    }
}

