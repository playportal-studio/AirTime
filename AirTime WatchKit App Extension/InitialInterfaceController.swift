//
//  InitialInterfaceController.swift
//  AirTime WatchKit App Extension
//
//  Created by Jett Black on 9/10/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import WatchKit

class InitialInterfaceController: WKInterfaceController {
    
    @IBAction func startTapped() {
        print("START JUMPING!")
        WKInterfaceController.reloadRootPageControllers(withNames: ["ChallengeInterfaceController"], contexts: [], orientation: WKPageOrientation.horizontal, pageIndex: 0)
        
//        WKInterfaceController.reloadRootControllers(withNames: ["ChallengeInterfaceController"], contexts: [])
    }
    
}
