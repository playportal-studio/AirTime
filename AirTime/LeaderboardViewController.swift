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


class Leaderboard : Codable {
    var totalJumps: Int!
    var totalJumpAttempts: Int!
    var maxSingleJumpCount:Int!
    var maxSingleHangTime:Double!
    
    init(json: Any) {
        print("in Leaderboard: json= \( json )" )
        if let json2 = json as? [String: Any] {
            totalJumps = json2["totalJumps"] as! Int
            totalJumpAttempts = json2["totalJumpAttempts"] as! Int
            maxSingleJumpCount = json2["maxSingleJumpCount"] as! Int
            maxSingleHangTime = json2["maxSingleHangTime"] as! Double
        }
    }
}

class LeaderboardViewController: UIViewController {
    
    @IBOutlet weak var profilePicGradient: GradientBkgndView!
    @IBOutlet weak var profilePicBlack: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var upperScoreLabel: UILabel!
    @IBOutlet weak var lowerScoreLabel: UILabel!
    



    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicGradient.layer.cornerRadius = profilePicGradient.frame.height / 2.0
        profilePicGradient.clipsToBounds = true
        profilePicBlack.layer.cornerRadius = profilePicBlack.frame.height / 2.0


    
    }
    
    
    func rightButton() {
    
     self.performSegue(withIdentifier:"showSettings", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

 
    
 

}
