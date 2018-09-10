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
        WKInterfaceController.reloadRootControllers(withNames: ["ChallengeInterfaceController"], contexts: [])
    }
    
}
