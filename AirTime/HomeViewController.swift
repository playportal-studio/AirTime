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
            self.session = WCSession.default
            self.session?.delegate = self
            self.session?.activate()
        }
        if user != nil {
            if user.anonymous {
                self.label.text = "@guest | Guest User"
                self.profilePicImageView.image = UIImage(named: "Unknown")
            } else {
                let h = self.user?.handle
                let fu = self.user?.firstName
                let lu = self.user?.lastName
                if h != nil && fu != nil && lu != nil {
                    self.label.text = h! + " | " + fu! + " " + lu!
                }
            }
            self.profilePicImageView.playPortalProfilePic(forImageId: self.user.profilePic, { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print("Error requesting profile pic: \(String(describing: error))")
                } else {
                    DispatchQueue.main.async {
                        self.profilePicImageView.layer.borderWidth = 1.0
                        self.profilePicImageView.layer.masksToBounds = false
                        self.profilePicImageView.layer.borderColor = UIColor.white.cgColor
                        self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.height / 2
                        self.profilePicImageView.clipsToBounds = true
                    }
                }
            })
        }
    }
    
    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        guard let settings = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Settings") as? SettingsTableTableViewController else {
            print()
            return
        }
        settings.user = user
        present(settings, animated: true, completion: nil)
    }
    
    @IBAction func playPORTALTapped(_ sender: UIBarButtonItem) {
        Utils.openOrDownloadPlayPortal(delegate: self)
    }
    
    @objc func leaderboardTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let leaderboard = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leaderboardTableViewController") as? LeaderboardTableViewController else {
            return
        }
        leaderboard.user = user
        present(leaderboard, animated: true, completion: nil)
    }
    
    func storeMyStatsToServer() {
        PlayPortalDataClient.shared.update(bucketNamed: "updatedAirTime", atKey: "totalJumpCount", withValue: myStats.totalJumps) { (Error, Any) in
                print("error writing to bucket for key: totalJumpCount")
            }
            
        PlayPortalDataClient.shared.update(bucketNamed: "updatedAirTime", atKey: "maxSingleJumpCount", withValue: myStats.maxSingleJumpCount) { (Error, Any) in
                print("error writing to bucket for key: maxSingleJumpCount")
            }
            
        PlayPortalDataClient.shared.update(bucketNamed: "updatedAirTime", atKey: "totalJumpAttempts", withValue: myStats.totalJumpAttempts) { (Error, Any) in
                print("error writing to bucket for key: totalJumpAttempts")
            }
        
        PlayPortalDataClient.shared.update(bucketNamed: "updatedAirTime", atKey: "maxSingleHangTime", withValue: myStats.maxSingleHangTime) { (Error, Any) in
                print("error writing to bucket for key: maxSingleHangTime")
            }
                PlayPortalLeaderboardClient.shared.updateLeaderboard(Double(myStats.totalJumps), forCategories: ["totalJumps"]) { (Error, PlayPortalLeaderboardEntry) in
                    print("problems updating leaderboard for key totalJumps:", Error as Any)
                }
            
                PlayPortalLeaderboardClient.shared.updateLeaderboard(Double(myStats.maxSingleHangTime), forCategories: ["maxAirTime"],  { (Error, PlayPortalLeaderboardEntry) in
                    print("problems updating leaderboard for key maxAirTime:", Error as Any)
                }
        )
}
    
    func storeRawDataToServer(jumpCount:Int, longestJump: Double) {
        
        PlayPortalDataClient.shared.update(bucketNamed: "updatedAirTime", atKey: "jumpCount", withValue: myStats.totalJumps) { (Error, Any) in
            print("error writing to bucket for key: jumpCount")
        }
        
        PlayPortalDataClient.shared.update(bucketNamed: "updatedAirTime", atKey: "longestJump", withValue: myStats.maxSingleHangTime) { (Error, Any) in
            print("error writing to bucket for key: longestJump")
        }
    }

    func updateStats(jumpCount:Int, longestJump: Double) {
        myStats.totalJumps = myStats.totalJumps + jumpCount
        myStats.totalJumpAttempts =  myStats.totalJumpAttempts + 1
        if jumpCount > myStats.maxSingleJumpCount { myStats.maxSingleJumpCount = jumpCount }
        if longestJump > myStats.maxSingleHangTime { myStats.maxSingleHangTime = longestJump }
        return storeMyStatsToServer()
    }
        
     
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
       DispatchQueue.main.async {
        let total = applicationContext["totalJumps"] as! Int
        let longest = Double(round(100*(applicationContext["longestJump"] as! Double))/100)
            self.upperScoreLabel.text = String(describing: total)
            self.lowerScoreLabel.text = String(describing: longest)
            self.updateStats(jumpCount:total, longestJump: longest) 
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
