//
//  RemoteNotifications.swift
//  iOKidsShared
//
//  Created by blackCloud on 12/20/16.
//  Copyright © 2018 Dynepic. All rights reserved.
//
import Foundation
import UserNotifications
import UIKit

public typealias RemoteNotificationsCompletion = (_ success: Bool) -> Void

private typealias DidReceiveDeviceTokenCompletion = (_ deviceToken: String) -> Void

public class RemoteNotificationsHandler {
    
    public static let sharedInstance = RemoteNotificationsHandler()
    
    private init() {}
    
    private var didReceiveDeviceTokenCompletion: DidReceiveDeviceTokenCompletion?

/*
    public private(set) var hasRegisteredDeviceToken: Bool {
        //        get { return store.state.savedState.hasRegisteredDeviceToken }
        //        set { store.dispatchAndLog(SavedStateAction.setHasRegisteredDeviceToken(val: newValue)) }
        get { return PPManager.sharedInstance.getAPNSdDeviceToken() != "" }
        set { PPManager.sharedInstance.setHasRegisteredDeviceToken(val: newValue)) }
    }
*/
    //  Registers for notifications if request for notifications are granted
    public func requestRemoteNotifications(completion: RemoteNotificationsCompletion? = nil) {
        
        //  First check if notifications are authorized for the app
        checkAuthorization { [weak self] granted in
            guard granted, let strongSelf = self else { completion?(false); return }
            
            //  Make call to get device token
            UIApplication.shared.registerForRemoteNotifications()
            
            //  Set completion to be called once device token is returned
            strongSelf.didReceiveDeviceTokenCompletion = { deviceToken in
                
                //  save device token
                PPManager.sharedInstance.setAPNSDeviceToken(token:  deviceToken)
            }
        }
    }
    
    //  Called by AppDelegate when it receives a device token
    public func didRegisterForRemoteNotifications(with data: Data) {
        let deviceTokenString = extractToken(from: data)
        didReceiveDeviceTokenCompletion?(deviceTokenString)
    }
    
    //  Removes device token from user's session
    public func revokeRemoteNotifications(completion: RemoteNotificationsCompletion? = nil) {
        //  If notifications are already off, return
//        guard hasRegisteredDeviceToken else { completion?(false); return }
        
        //  First check if notifications are authorized for the app
        checkAuthorization { [weak self] granted in
            guard granted, let strongSelf = self else { completion?(false); return }
            
            //  Make call to get device token
            UIApplication.shared.registerForRemoteNotifications()
            
            //  Set completion to be called once device token is returned
            strongSelf.didReceiveDeviceTokenCompletion = { deviceToken in
                
                PPManager.sharedInstance.setAPNSDeviceToken(token: "")
            }
        }
    }
    
    //  Will check if the user has already granted authorization for push notifications; if not, will request it.
    public func checkAuthorization(_ completion: @escaping (_ granted: Bool) -> Void) {
        
        //  Check that user has allowed for push notifications
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //  Authorization status should either be authorized or notDetermined if requestAuthorization has never been called
            guard settings.authorizationStatus == UNAuthorizationStatus.authorized || settings.authorizationStatus == UNAuthorizationStatus.notDetermined else { completion(false); return }
            
            //  Request authorization for notifications
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) {  granted, error in
                completion(granted)
            }
        }
    }
}

private extension RemoteNotificationsHandler {
    
    /**
     Receives device token data from application(_:didRegisterForRemoteNotificationsWithDeviceToken:) and returns it as uppercase hex.
     - parameters:
     - deviceToken: Device token as type Data returned after a user has registered for remote notifications.
     - returns: Device token converted to uppercase hex.
     */
    func extractToken(from deviceToken: Data) -> String {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        return token.uppercased();
    }
}
