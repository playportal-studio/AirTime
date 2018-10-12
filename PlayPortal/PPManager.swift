//
//  PPManager.swift
//  PlayPortal
//
//  Created by Gary J. Baldwin on 9/12/18.
//  Copyright © 2018 Dynepic. All rights reserved.
//

import Foundation
import Security
import Alamofire
import KeychainSwift


func notListening(_ user: PPUserObject?, _ isAuthd: Bool) -> Void {
    if isAuthd {
        print("Error: I'm listening, but somebody else should be!")
    } else {
        print("Error: No one is listening!")
    }
}

class PPManager {
    private var refreshToken:String = ""
    private var expirationTime: Date?
    private var apnsDeviceToken:String = ""
    private var apiUrlBase:String = ""
    var accessToken:String = ""
    private var env:String = ""
    private var cid:String = ""
    private var cse:String
    private var redir:String
    
    var userListener:(_ user: PPUserObject?, _ isAuthd: Bool) -> Void
    
    var PPusersvc: PPUserService!
    var PPwebapi: PPWebApi!
    var PPdatasvc: PPDataService!
    
    //    var keychain: KeychainWrapper = KeychainWrapper()
    let keychain = KeychainSwift()
    
    public init() {
        env = "SANDBOX"
        apiUrlBase = "https://sandbox.playportal.io"
        cid = ""
        cse = ""
        redir = ""
        
        //    keychain = KeychainWrapper()
        PPusersvc = PPUserService(keychain:keychain)
        PPdatasvc = PPDataService()
        
        
        if keychain.get("apns_device_token") != nil { } else {apnsDeviceToken = ""}
        if keychain.get("refresh_token") != nil { } else {refreshToken = ""}
        if keychain.get("access_token") != nil { } else {accessToken = ""}
        expirationTime = Date()
        PPwebapi = nil
        
        userListener = notListening
    }
    
    static let sharedInstance: PPManager = {
        let instance = PPManager()
        
        return instance
    }()
    
    
    func getApiUrlBase() -> String { return PPManager.sharedInstance.apiUrlBase }
    func getClientId() -> String { return PPManager.sharedInstance.cid }
    func getRedirectURI() -> String { return PPManager.sharedInstance.redir }
    func getImAnnonymousStatus() -> Bool { return false }
    func getAccessToken() -> String { return self.accessToken   }
    
    func addUserListener(handler:@escaping (_ user: PPUserObject?, _ isAuthd: Bool) -> Void) -> Void {
        PPManager.sharedInstance.userListener = handler
    }
    
    func updateAPNSDeviceToken(apnsDeviceToken: NSData) -> Void {
        let t:String = String(data: apnsDeviceToken as Data, encoding: .utf8)!
        PPManager.sharedInstance.apnsDeviceToken = t;
        PPManager.sharedInstance.keychain.set(t, forKey:"apns_device_token")
    }
    
    func configure(env:String, clientId:String, secret:String, andRedirectURI:String) -> Void  {
        if(clientId.isEmpty || secret.isEmpty || andRedirectURI.isEmpty) {
            print("ERROR: configure invalid parms: clientId: \(clientId)  secret: \(secret)  andRedirectURI: \(andRedirectURI) ")
        } else {
            // this setup code is run once
            if (env == "DEV") {
                apiUrlBase = "\("https://develop-api.goplayportal.com")"
            } else if (env == "PRODUCTION") {
                apiUrlBase = "https://api.playportal.io"
            } else {
                apiUrlBase = "https://sandbox.playportal.io"
            }
            cid = clientId
            cse = secret
            redir = andRedirectURI
            
            //            keychain = KeychainWrapper()
            //            keychain = KeychainSwift()
            PPusersvc = PPUserService(keychain:keychain)
            PPdatasvc = PPDataService()
            
            if let a = keychain.get("apns_device_token") {
                apnsDeviceToken = a
            } else {
                apnsDeviceToken = ""
            }
        
            if let r = keychain.get("refresh_token") {
                refreshToken = r
            } else {
                refreshToken = ""
            }
        
            if let a = keychain.get("access_token") {
                accessToken = a
            } else {
                accessToken = ""
            }
            
            print("Configure refreshToken: \(refreshToken )  accessToken: \(accessToken ) ") 
            if let ds:String = keychain.get("expiration_time") {
                expirationTime = dateFromString(datestring: ds)
            } else {
                keychain.set(stringFromDate(date: Date()), forKey: "expiration_time")
            }
            
            PPwebapi = PPWebApi(clientId: clientId, clientSecret: secret, baseURLString: apiUrlBase, accessToken: accessToken, refreshToken: refreshToken, keychain: keychain)
            
            PPManager.sharedInstance.cid = clientId;
            PPManager.sharedInstance.cse = secret;
            PPManager.sharedInstance.redir = andRedirectURI;
            
            PPManager.sharedInstance.isAuthenticated() { isAuthd in
                PPManager.sharedInstance.getProfileAndBucket { error in
                    if(!error.isEmpty) { print("ERROR: configure \(error)") }
                    PPManager.sharedInstance.PPusersvc.getProfile {  succeeded, response, user in
                        if(!succeeded) {
                            print("Error:", response.debugDescription)
                            PPManager.sharedInstance.userListener(nil, isAuthd)
                        } else {
                            PPManager.sharedInstance.userListener(user, isAuthd)
                        }
                    }
                }
            }
        }
    }
    
    func getProfileAndBucket(handler: @escaping (_ error:String) -> Void) {
        PPManager.sharedInstance.PPusersvc.getProfile {  succeeded, response, user in
            if(!succeeded) {
                print("Error:", response.debugDescription)
                handler(response.debugDescription);
            } else {
                // attempt to create / open this user's private data storage
                if let id = PPManager.sharedInstance.PPusersvc.user.u["userId"] {
                    PPManager.sharedInstance.PPdatasvc.openBucket(bucketName:PPManager.sharedInstance.PPusersvc.getMyDataStorageName(), users:[id], isPublic:false) { succeeded, response, img in
                            print("getProfileAndBucket openBucket (my appData) succeeded: \( succeeded)" )
                        }
                    PPManager.sharedInstance.PPdatasvc.openBucket(bucketName:PPManager.sharedInstance.PPusersvc.getMyAppGlobalDataStorageName(), users:[], isPublic:true) { succeeded, response, img in
                            print("getProfileAndBucket openBucket (global) succeeded: \( succeeded)" )
                    }
                }
                handler("nil")                
            }
        }
    }
    
    
    // After SSO, redirect sends app here to begin
    func handleOpenURL(url: URL) -> Void {
        print("handleOpenURL")
        extractAndSaveTokens(u: url)
        PPManager.sharedInstance.PPwebapi.hydrateTokens(accessToken: PPManager.sharedInstance.accessToken, refreshToken: PPManager.sharedInstance.refreshToken)
        PPManager.sharedInstance.PPwebapi.oauthHandler.refreshAccessTokens { succeeded, accessToken, refreshToken in
            
            PPManager.sharedInstance.getProfileAndBucket { error in
                if (error.isEmpty || error == "nil") {
                    var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                    while (topController.presentedViewController != nil) {
                        topController = topController.presentedViewController!;
                    }
                    topController.dismiss(animated:true) {
                        PPManager.sharedInstance.getProfileAndBucket { error in
                            if(!error.isEmpty) { print("ERROR: configure \(error)") }
                            PPManager.sharedInstance.PPusersvc.getProfile {  succeeded, response, user in
                                if(!succeeded) {
                                    print("Error:", response.debugDescription)
                                    PPManager.sharedInstance.userListener(nil, false)
                                } else {
                                    PPManager.sharedInstance.userListener(user, true)
                                }
                            }
                        }
                    }
                } else {
                    self.dismissTopVC()
                }
            }
        }
    }
    
    
    func dismissTopVC() -> Void {
        var topController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        topController.dismiss(animated:true, completion:nil)
    }
    
    func getAPNSdDeviceToken() -> String? {
        let a = keychain.get("apnsDeviceToken")
        return a
    }
    
    func setAPNSDeviceToken(token: String) {
         PPManager.sharedInstance.keychain.set("", forKey:"apnsDeviceToken")
    }
    
    func storeTokensInKeychain() ->  Void {
        PPManager.sharedInstance.keychain.set(refreshToken, forKey:"refresh_token")
        PPManager.sharedInstance.keychain.set(accessToken, forKey:"access_token")
        let etString = PPManager.sharedInstance.stringFromDate(date: PPManager.sharedInstance.expirationTime!)
        PPManager.sharedInstance.keychain.set(etString, forKey:"expiration_time")
    }
    
    // After SSO auth, get a refresh token, access token and expiration time- use for validating API requests
    func extractAndSaveTokens(u: URL) -> Void {
        let queryItems = URLComponents(url: u, resolvingAgainstBaseURL: false)?.queryItems
        let rt = queryItems?.filter({$0.name == "refresh_token"}).first
        let at = queryItems?.filter({$0.name == "access_token"}).first
        let et = queryItems?.filter({$0.name == "expires_in"}).first
        print("refreshToken: \(String(describing: rt?.value ))")
        print("accessToken: \(String(describing: at?.value ))")
        print("expiration period: \(String(describing: et?.value ))")
        
        PPManager.sharedInstance.refreshToken = (rt?.value)!
        PPManager.sharedInstance.accessToken = (at?.value)!
        var interval: Double = 3600 * 12
        if(et?.value != "1d") {
            interval = 60
        }
        PPManager.sharedInstance.expirationTime = Date.init(timeIntervalSinceNow:(interval))
        storeTokensInKeychain()
    }
    
    func getIsAuthenticated() -> Bool  {
        return (PPManager.sharedInstance.allTokensExist() && PPManager.sharedInstance.tokensNotExpired())
    }
    
    func isAuthenticated(handler: @escaping (_ isAuthd:Bool) -> Void) {
        if(allTokensExist()) { // force a refresh
            PPManager.sharedInstance.PPwebapi.oauthHandler.refreshAccessTokens { succeeded, accessToken, refreshToken in
                if let accessToken = accessToken, let refreshToken = refreshToken {
                    PPManager.sharedInstance.keychain.set(accessToken, forKey: "access_token")
                    PPManager.sharedInstance.keychain.set(refreshToken, forKey: "refresh_token")
                    handler(true)
                } else {
                    handler(false)
                }
            }
        } else { // force a re-login
            PPManager.sharedInstance.logout()
            handler(false)
        }
    }
    
    func allTokensExist() -> Bool {
        if keychain.get("refresh_token") != nil {
            if let _:String =  keychain.get("expiration_time") {
                return true
            }
        }
        return false
    }
    
    func tokensNotExpired() -> Bool {
        let now:Date = Date()
        let ds:String = PPManager.sharedInstance.keychain.get("expiration_time")!
        if(ds.isEmpty) { return false }
        
        let exp:Date = PPManager.sharedInstance.dateFromString(datestring:ds)
        if(now.compare(exp) ==  ComparisonResult.orderedAscending) {
            return true
        } else {
            return false
        }
    }
    
    func logout() -> Void {
        PPManager.sharedInstance.accessToken = ""
        PPManager.sharedInstance.keychain.set("", forKey:"access_token")
        PPManager.sharedInstance.refreshToken = ""
        PPManager.sharedInstance.keychain.set("", forKey:"refresh_token")
        PPManager.sharedInstance.expirationTime = Date()
        PPManager.sharedInstance.keychain.set("", forKey:"expiration_time")
        
        // Call userListener with auth status = false
        PPManager.sharedInstance.userListener(nil, false);
        
    }
    
    func getDeviceToken() -> String {
        return "unknown";
    }
    
    func dateFromString(datestring: String) -> Date {
        if(datestring.isEmpty || datestring == "") {
            return Date()
        }
        let rfc3339DateFormatter: DateFormatter = DateFormatter()
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        rfc3339DateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return rfc3339DateFormatter.date(from: datestring)!
    }
    
    func stringFromDate(date: Date) -> String {
        let rfc3339DateFormatter:DateFormatter = DateFormatter()
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        rfc3339DateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return rfc3339DateFormatter.string(from: date)
    }
}
