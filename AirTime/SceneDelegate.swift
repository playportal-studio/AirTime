//
//  SceneDelegate.swift
//  AirTime
//
//  Created by Joshua Paulsen on 11/21/19.
//  Copyright © 2019 Dynepic, Inc. All rights reserved.
//

import Foundation
import UIKit
import PPSDK_Swift

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate, PlayPortalLoginDelegate {
    
    var window: UIWindow?
    var user: PlayPortalProfile?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            DispatchQueue.main.async {
                PlayPortalAuth.shared.open(url: url)
            }
        }
    }
    
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//         PlayPortalAuth.shared.configure(forEnvironment: env, withClientId: clientId, andClientSecret: clientSecret, andRedirectURI: redirect)
//
//               authenticate()
//    }
//
//    func authenticate() {
//           PlayPortalAuth.shared.isAuthenticated(loginDelegate: self) { [weak self] error, userProfile in
//               guard let self = self else { return }
//               if let userProfile = userProfile {
//                   //  User is authenticated, go to initial
//                   guard let home = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home" ) as? HomeViewController else { return }
//                   home.user = userProfile
//                   self.window?.rootViewController = home
//               } else if let error = error {
//                   print("Error during authentication: \(error)")
//               } else {
//                   //  Not authenticated, open login view controller
//                   print("User not authenticated, go to login")
//                   guard let login = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
//                       return
//                   }
//                   self.window?.rootViewController = login
//               }
//           }
//       }
}
