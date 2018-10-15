//
//  HomeViewController.swift
//  AirTime
//
//  Created by Jett Black on 9/7/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit
import WatchConnectivity
/*
class RawJumpData : Codable {
    var jumpEvents:[ String: Any]!
    
    init(json: Any) { }
}
*/


class Stats : Codable {
    var totalJumps: Int!
    var totalJumpAttempts: Int!
    var maxSingleJumpCount:Int!
    var maxSingleHangTime:Double!
    
    init(json: Any) {
        print("in Stats: json= \( json )" )
        if let json2 = json as? [String: Any] {
            totalJumps = json2["totalJumps"] as! Int
            totalJumpAttempts = json2["totalJumpAttempts"] as! Int
            maxSingleJumpCount = json2["maxSingleJumpCount"] as! Int
            maxSingleHangTime = json2["maxSingleHangTime"] as! Double
        }
    }
}

class HomeViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var profilePicGradient: GradientBkgndView!
    @IBOutlet weak var profilePicBlack: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var upperScoreLabel: UILabel!
    @IBOutlet weak var lowerScoreLabel: UILabel!
    
    var session: WCSession?
    
    var user:PPUserObject?
    

//    var myRawJumpData:RawJumpData!

    var myStats:Stats = Stats(
        json: [ "totalJumps": 0 as Int,
                "totalJumpAttempts" : 0 as Int,
                "maxSingleJumpCount":  0 as Int,
            "maxSingleHangTime": 0.1 ] )
    

    func userListener(_ user:PPUserObject?, _ authd:Bool) -> Void {
        print("userListener invoked authd: \( authd )  user: \(String(describing:  user ))" )
        
        let sb:UIStoryboard = UIStoryboard.init(name:"Main", bundle:nil)
        guard let rvc:UIViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        if(!authd) {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicGradient.layer.cornerRadius = profilePicGradient.frame.height / 2.0
        profilePicGradient.clipsToBounds = true
        profilePicBlack.layer.cornerRadius = profilePicBlack.frame.height / 2.0
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.height / 2.0

        
        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "logo_small"), style: .plain, target: self, action: #selector(HomeViewController.leftButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(HomeViewController.rightButton))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if (WCSession.isSupported()) {
            self.session = WCSession.default()
            self.session?.delegate = self
            self.session?.activate()
        }
        let h = self.user?.get(key: "handle")
        let fu = self.user?.get(key:"firstName")
        let lu = self.user?.get(key:"lastName")
        if h != nil && fu != nil && lu != nil {
            self.label.text = h! + " | " + fu! + " " + lu!
            
            PPManager.sharedInstance.PPusersvc.getProfilePic { succeeded, response, img in
                if succeeded {
                    if let i = img {
                        self.profilePicImageView.image = i
                        self.profilePicImageView.layer.masksToBounds = true

                    }
                }
            }
        }
    }
    
    func rightButton() {
    
     self.performSegue(withIdentifier:"showSettings", sender: self)
    }
    
    func leftButton() {
       Utils.openOrDownloadPlayPortal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func storeMyStatsToServer(completion: @escaping PPDataCompletion) {
        let s:String = PPManager.sharedInstance.PPusersvc.user.get(key: "handle")!
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
        }
    
    func storeRawDataToServer(jumpCount:Int, longestJump: Double, completion: @escaping PPDataCompletion) {
        let s:String = PPManager.sharedInstance.PPusersvc.user.get(key: "handle")!
        let jc:NSNumber = jumpCount as NSNumber
        let lj: NSNumber = longestJump as NSNumber
        let tnow = PPManager.sharedInstance.stringFromDate(date: Date())
        let innerd = ["user": s, "jump count": jc, "longest jump":lj, "epoch": tnow] as [String: Any]
//       self.myRawJumpData.append(json: innerd)
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
        print("WHATEVS")
    }

}
