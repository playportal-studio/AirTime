//
//  PPUserService.swift
//  Helloworld-Swift-SDK
//
//  Created by Gary J. Baldwin on 9/15/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import QuartzCore
import SafariServices
import Alamofire
import KeychainSwift

typealias PPUserCompletion = (_ succeeded: Bool, _ response: Any?, _ responseObject: PPUserObject?) -> Void
typealias PPImageCompletion = (_ succeeded: Bool, _ response: Any?, _ responseObject: UIImage?) -> Void
//typealias PPFriendsCompletion = (_ succeeded: Bool, _ response: Any?, _ responseObject: [PPUserObject]?) -> Void
typealias PPFriendsCompletion = (_ succeeded: Bool, _ response: Any?, _ responseObject: [Friend]?) -> Void

class UserCodable: Codable {
    var accountType: String!
    var anonymous:Bool!
    var country: String!
    var coverPhoto: String!
    var handle: String!
    var firstName: String!
    var lastName: String!
    var profilePic: String!
    var userId: String!
    var userType: String!
    var parentFlags: [String:Bool]!

    
    init(json: Any) {
        print("in UserCodable: json= \( json )" )
        if let json2 = json as? [String: Any] {
            if let at = json2["accountType"] as! String? { accountType = at }
            anonymous = false
            if let cnt = json2["country"] as! String? { country = cnt }
            if let c = json2["coverPhoto"] as? String { coverPhoto = c }
            if let h = json2["handle"] as! String? { handle = h }
            if let f = json2["firstName"] as! String? { firstName = f }
            if let l = json2["lastName"] as! String? { lastName = l }
            if let p = json2["profilePic"] as? String? { profilePic = p }
            if let uid = json2["userId"] as! String? { userId = uid }
            if let ut = json2["userType"] as! String?  { userType = ut }
            if let pf:[String:Bool] = json2["parentFlags"] as? [String: Bool] { parentFlags = pf } else {
                parentFlags = ["cameraDisabled": false, "proximityFriends": true]
            }
        }
    }
}

class PPUserObject {
    // This class maintains 2 main objects for the user. One is the userObject uo and the other is a dictionary, "uPics" containing the user's profile and cover images
    var uo: UserCodable
    
    // Contains one or more of (as UIImage)  where key is in { "profilePic", "coverPic" }
    var uPics: [String: UIImage]
    
    init() {
        let u:[String:String] = [:]
        uPics = [:]
        uo = UserCodable(json:u)
    }
    
    func setImage(value:UIImage, key:String) -> Void {
        uPics.updateValue(value as UIImage, forKey: key)
    }
    func getImage(key:String) -> UIImage? {
        if let img = uPics[key] {
            return img
        }
        return nil
    }
    
}

class Friend : PPUserObject, Codable {
    
    var accountType: String!
    var anonymous:Bool!
    var country: String!
    var coverPhoto: String!
    var handle: String!
    var firstName: String!
    var lastName: String!
    var profilePic: String!
    var userId: String!
    var userType: String!
    
    init(json: Any) {
        //            let json2 = json as? [String:Any]
        print("in Friend: json= \( json )" )
        if let json2 = json as? [String: Any] {
            //                if let number = dictionary["someKey"] as? Double {
            // access individual value in dictionary
            
            print("converting json to friend")
            accountType = json2["accountType"] as! String
            anonymous = false
            country = json2["country"] as! String
            if let c = json2["coverPhoto"] as? String {
                coverPhoto = c
            }
            handle = json2["handle"] as! String
            firstName = json2["firstName"] as! String
            lastName = json2["firstName"] as! String
            if let p = json2["profilePic"] as? String {
                profilePic = p
            }
            userId = json2["userId"] as! String
            userType = json2["userType"] as! String
        }
    }
}

class PPUserService {
    var user: PPUserObject // contains all user fields and images (if downloaded)
    var userProfileIsValid: Bool
    var isAnonymousUser: Bool?

        var myFriends: [Friend] // Array of Friends

    init(keychain:KeychainSwift) {
        userProfileIsValid = false
        user = PPUserObject()  // user data is contained in the userObject
        
        if let v = keychain.get("handle") { user.uo.handle = v }
        if let v = keychain.get("userId") { user.uo.userId = v }
        if let v = keychain.get("userType") { user.uo.userType = v }
        if let v = keychain.get("firstName") { user.uo.firstName = v }
        if let v = keychain.get("lastName") { user.uo.lastName = v }
        if let v = keychain.get("county") { user.uo.country = v }
        if let v = keychain.get("accountType") { user.uo.accountType = v }
        if let v = keychain.get("userType") { user.uo.userType = v }
        if let v = keychain.get("profilePicId") { user.uo.profilePic = v }
        if let v = keychain.get("coverPhotoId") { user.uo.coverPhoto = v }

        isAnonymousUser = false
        myFriends = []
    }
    
    // ----------------------------------------------------------------
    // user methods
    // ----------------------------------------------------------------
    // If user isn't currently authenticated with server, then perform oauth login
    func login() -> Void {
        let pre: String = PPManager.sharedInstance.getApiUrlBase()
        let slug: String =  "/oauth/signin?client_id="
        let cid: String = PPManager.sharedInstance.getClientId()
        let mid: String = "&redirect_uri="
        let uri: String = PPManager.sharedInstance.getRedirectURI()
        let post: String = "&state=beans&response_type=implicit"
        
        let url: String = pre + slug + cid + mid + uri + post
        print("Login url: \(url)")
 
        let _svc = SFSafariViewController(url: NSURL(string: url)! as URL)
        _svc.modalTransitionStyle = UIModalTransitionStyle.coverVertical

        var topController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!;
        }
        
        topController.present(_svc, animated:true, completion:nil)
    }  
    
    
    func loginAnonymously(birthdate: NSDate) -> Void {
//        NSLog(@"%@ app user logging in anonymously...", NSStringFromSelector(_cmd));
/*
        let urlString:String = PPManager.sharedInstance.apiUrlBase + "/user/v1/my/profile"
        PPManager.sharedInstance.setImAnonymousStatus(true)
    

    NSDictionary *body = @{@"anonymous":@"TRUE", @"dateOfBirth": [PPManager stringFromNSDate:birthdate], @"clientId":[PPManager sharedInstance].clientId, @"deviceToken": [[PPManager sharedInstance] getDeviceToken]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *req = [PPManager buildAFRequestForBodyParms: @"PUT" andUrlString:urlString];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
    if (!error) {
    NSDictionary *dictionary = [(NSHTTPURLResponse*)response allHeaderFields]; // Capture accessToken and refreshToken from header
    [[PPManager sharedInstance] extractAndSaveTokens:dictionary];
    NSLog(@"%@ response: %@", NSStringFromSelector(_cmd), dictionary);
    NSLog(@"%@ Reply JSON: %@", NSStringFromSelector(_cmd), responseObject);
    
    NSDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
    [[PPManager sharedInstance].PPuserobj inflateWith:user];
    
    [[PPManager sharedInstance].PPdatasvc openBucket:[PPManager sharedInstance].PPuserobj.myDataStorage andUsers:(NSArray *)[NSArray arrayWithObjects:[PPManager sharedInstance].PPuserobj.userId, nil] public:@"FALSE" handler:^(NSError* error) {
    if(error) {
    NSLog(@"%@ Error: Unable to open/create user bucket - %@", NSStringFromSelector(_cmd), error);
    [PPManager sharedInstance].PPusersvc.addUserListener(NULL, error);
    } else {
    NSLog(@"%@ Open/create user bucket for user: %@", NSStringFromSelector(_cmd), user);
    }
    }];
    } else {
    [PPManager processAFError:error withRetryBlock:NULL];
    NSLog(@"%@ Error %@ %@ %@", NSStringFromSelector(_cmd), error, response, responseObject);
    [PPManager sharedInstance].PPusersvc.addUserListener(NULL, error);
    }
    }] resume];
*/
 }
    
    
    func markUserInvalid() -> Void {
        userProfileIsValid = false
    }
    func logout() -> Void {
        markUserInvalid()
        PPManager.sharedInstance.logout()
    }
    
    func getProfile(completion: @escaping PPUserCompletion ) {
        if(userProfileIsValid) {
            completion(true, nil, user)
        } else {
            // get user profile from server
            PPManager.sharedInstance.PPwebapi.getUserProfile{ succeeded, response, responseObject in
                print("userprofile read from server:")
                if(succeeded) {
//                    self.user.u = responseObject as! [String:String]
                    self.user.uo = UserCodable(json:responseObject!)
                    self.userProfileIsValid = true
                    completion(true, response, self.user)
                } else {
                    completion(false, nil, nil)
                }
            }
        }
    }


    func getAppNameFromBundle() -> String {
        let items = Bundle.main.bundleIdentifier!.split(separator: ".")
        return String(items.last!).lowercased()
    }
    
    func getMyDataStorageName() -> String {
        if let h:String = user.uo.handle {
            return h + "@" + getAppNameFromBundle()
        } else {
            return nil!
        }
    }
    
    func getMyAppGlobalDataStorageName() -> String {
        return "globalAppData@" + getAppNameFromBundle()
    }
    

    func getProfilePic(completion: @escaping PPImageCompletion ) {
//        if let img:UIImage = user.getImage(key:"profilePic") {
//            print("getProfilePic (from cache) for user: \( user.uo.handle )" )
//            completion(true, nil, img)
//        } else {
            PPManager.sharedInstance.PPwebapi.getProfileOrCoverImage(isProfile: true) { succeeded, response, responseObject in
                print("getProfilePic from server:")
                    if(succeeded) {
                        self.user.uPics["profilePic"] = responseObject as? UIImage
                        completion(true, nil, self.user.uPics["profilePic"])
                    } else {
                        completion(true, nil, UIImage(named: "anonUser"))
                }
                }
//            }
//        completion(true, nil, UIImage(named: "anonUser"))
    }   
        
    func getCoverPic(completion: @escaping PPImageCompletion ) {
        if let img:UIImage = user.getImage(key:"coverPic") {
            completion(true, nil, img)
        } else {
            PPManager.sharedInstance.PPwebapi.getProfileOrCoverImage(isProfile: true) { succeeded, response, responseObject in
                print("getCoverPic from server:")
                if(succeeded) {
                    self.user.uPics["profilePic"] = responseObject as? UIImage
                    completion(true, nil, self.user.uPics["coverPic"])
                }
            }
        }
        completion(true, nil, UIImage(named: "anonUserCover"))
    }


    // ----------------------------------------------------------------
    // Friends methods
    // ----------------------------------------------------------------
    func getFriendsProfiles(completion: @escaping PPFriendsCompletion ) {
        PPManager.sharedInstance.PPwebapi.getFriendsProfiles{ succeeded, response, responseObject in
            print("friendsprofiles read from server:")
            if(succeeded) {
//                self.myFriends = responseObject as! [PPUserObject]
                print("getFriendsProfiles response: \(String(describing: response ))" )
                print("getFriendsProfiles responseObject: \(String(describing: responseObject ))" )

                
                if let responseObject = responseObject,
                    let jarray = responseObject as? NSArray
                {
                    self.myFriends = []
                    for fr in jarray {
                        print("fr: \( fr )" )
                        let f = Friend(json: fr)
                        self.myFriends.append(f)
                    }
                }
                completion(true, response, self.myFriends)
            } else {
                completion(false, nil, nil)
            }
        }
        completion(false, nil, [])
    }
       
    func getFriendsCount() -> Int {
        let c = myFriends.count
        print("PPUserService myFriends.count= \( c )" )
        return c
    }
    
    func getFriendsProfilePic(_ friendId: String) -> UIImage? {
        if let f = getFriendById(friendId) {
            if let img:UIImage = f.getImage(key:f.uo.profilePic!) {
                return img
            }
        }
        return UIImage(named: "anonUser")
    }

    func getFriendById(_ friendId: String) -> Friend? {
        for f in self.myFriends { if f.userId == friendId { return f } }
        return nil
    }

    func getFriendAtIndex(_ index: NSInteger) -> Friend? {
        if(index < myFriends.count) { return myFriends[index]} else { return nil }
    }
    
    func getFriendAtIndexAsArray(_ index: NSInteger) -> Friend? {
        if(index < myFriends.count) { return myFriends[index] } else { return nil }
    }
}




