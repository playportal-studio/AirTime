//
//  SettingsContainerViewController.swift
//  AirTime
//
//  Created by Gary J. Baldwin on 9/21/18.
//  Copyright © 2018 Gary J. Baldwin. All rights reserved.
//

import Foundation
import UIKit

class SettingsContainerViewController: UIViewController {
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated:true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view.
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
}
