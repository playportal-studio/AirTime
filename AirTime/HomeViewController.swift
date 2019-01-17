//
//  HomeViewController.swift
//  AirTime
//
//  Created by Jett Black on 9/7/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit
import WatchConnectivity
import StoreKit
import PPSDK_Swift


class Stats : Codable {
    var totalJumps: Int!
    var totalJumpAttempts: Int!
    var maxSingleJumpCount:Int!
    var maxSingleHangTime:Double!
    
    init(json: Any) {
        print("in Stats: json= \( json )" )
        if let json2 = json as? [String: Any] {
            totalJumps = json2["totalJumps"] as? Int
            totalJumpAttempts = json2["totalJumpAttempts"] as? Int
            maxSingleJumpCount = json2["maxSingleJumpCount"] as? Int
            maxSingleHangTime = json2["maxSingleHangTime"] as? Double
        }
    }
}

class HomeViewController: UIViewController, WCSessionDelegate, SKStoreProductViewControllerDelegate {
    
    @IBOutlet weak var profilePicGradient: GradientBkgndView!
    @IBOutlet weak var profilePicBlack: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var upperScoreLabel: UILabel!
    @IBOutlet weak var lowerScoreLabel: UILabel!
    @IBOutlet weak var leaderboardImageView: UIImageView!
    
    var session: WCSession?
    
    var user: PlayPortalProfile!
    


    var myStats:Stats = Stats(
        json: [ "totalJumps": 0 as Int,
                "totalJumpAttempts" : 0 as Int,
                "maxSingleJumpCount":  0 as Int,
            "maxSingleHangTime": 0.1 ] )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicGradient.layer.cornerRadius = profilePicGradient.frame.height / 2.0
        profilePicGradient.clipsToBounds = true
        profilePicBlack.layer.cornerRadius = profilePicBlack.frame.height / 2.0
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.height / 2.0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(leaderboardTapped(tapGestureRecognizer:)))
        leaderboardImageView.isUserInteractionEnabled = true
        leaderboardImageView.addGestureRecognizer(tapGestureRecognizer)
        
        if (WCSession.isSupported()) {
            self.session = WCSession.default()
            self.session?.delegate = self
            self.session?.activate()
        }
        
        let h = self.user?.handle
        let fu = self.user?.firstName
        let lu = self.user?.lastName
        if h != nil && fu != nil && lu != nil {
            self.label.text = h! + " | " + fu! + " " + lu!
            
            DispatchQueue.main.async {
                self.profilePicImageView.layer.masksToBounds = true
                
                self.profilePicImageView.playPortalProfilePic(forImageId: self.user.profilePic, { error in
                    if let error = error {
                        print("Error requesting profile pic: \(String(describing: error))")
                    }
                }
              )
            }
        }
    }
    
    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        guard let settings = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Settings") as? SettingsTableTableViewController else {
            print()
            return
        }
        //settings.user = user
        present(settings, animated: true, completion: nil)
    }
    
    @IBAction func playPORTALTapped(_ sender: UIBarButtonItem) {
        Utils.openOrDownloadPlayPortal(delegate: self)
    }
    
    @objc func leaderboardTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let leaderboard = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leaderboardTableViewController") as? LeaderboardTableViewController else {
            return
        }
        present(leaderboard, animated: true, completion: nil)
    }
    
    func storeMyStatsToServer(completion: @escaping PPDataCompletion) {
        if let s:String = PPManager.sharedInstance.PPusersvc.user.uo.handle {
        let tnow = PPManager.sharedInstance.stringFromDate(date: Date())
        let innerd = ["user": s,
                      "Total jump count": myStats.totalJumps as Int,
                      "Max single jump count":myStats.maxSingleJumpCount as Int,
                      "Total jump attempts": myStats.totalJumpAttempts as Int,
                      "Max hang time": myStats.maxSingleHangTime,
                      "epoch": tnow] as [String: Any]
            PPManager.sharedInstance.PPdatasvc.writeBucket( bucketName:PPManager.sharedInstance.PPusersvc.getMyAppGlobalDataStorageName(), key:s, value:innerd) { succeeded, response, responseObject in
                if(!succeeded) { print("write JSON error:") }
            }
            
            PlayPortalLeaderboard.shared.updateLeaderboard(Double(myStats.totalJumps), forCategories: ["totalJumps"]) { (Error, PlayPortalLeaderboardEntry) in
                print("problems updating leaderboard for key totalJumps:", Error as Any)
            }
            
            PlayPortalLeaderboard.shared.updateLeaderboard(Double(myStats.maxSingleHangTime), forCategories: ["maxAirTime"],  { (Error, PlayPortalLeaderboardEntry) in
                print("problems updating leaderboard for key maxAirTime:", Error as Any)
            }
        )
    }
}
    
    func storeRawDataToServer(jumpCount:Int, longestJump: Double, completion: @escaping PPDataCompletion) {
        let s:String = PPManager.sharedInstance.PPusersvc.user.uo.handle!
        let jc:NSNumber = jumpCount as NSNumber
        let lj: NSNumber = longestJump as NSNumber
        let tnow = PPManager.sharedInstance.stringFromDate(date: Date())
        let innerd = ["user": s, "jump count": jc, "longest jump":lj, "epoch": tnow] as [String: Any]
        PPManager.sharedInstance.PPdatasvc.writeBucket( bucketName:PPManager.sharedInstance.PPusersvc.getMyAppGlobalDataStorageName(), key:s, value:innerd) { succeeded, response, responseObject in
            if(!succeeded) { print("write JSON error:") }
        }
    }

    func updateStats(jumpCount:Int, longestJump: Double, completion: @escaping PPDataCompletion) {
        myStats.totalJumps = myStats.totalJumps + jumpCount
        myStats.totalJumpAttempts =  myStats.totalJumpAttempts + 1
        if jumpCount > myStats.maxSingleJumpCount { myStats.maxSingleJumpCount = jumpCount }
        if longestJump > myStats.maxSingleHangTime { myStats.maxSingleHangTime = longestJump }
        return storeMyStatsToServer() { succeeded, response, responseObject in
        }
    }
        
        
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let total = applicationContext["totalJumps"] as! Int
        let longest = Double(round(100*(applicationContext["longestJump"] as! Double))/100)
        DispatchQueue.main.async {
            self.upperScoreLabel.text = String(describing: total)
            self.lowerScoreLabel.text = String(describing: longest)
            self.updateStats(jumpCount:total, longestJump: longest) {  succeeded, response, responseObject in
            }
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("diddeactivate")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("didbecomeinactive")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith")
    }

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
