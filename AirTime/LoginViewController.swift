//
//  LoginViewController.swift
//  AirTime
//
//  Created by Gary J. Baldwin on 9/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.textColor = UIColor.airtimeColors.yellow
        //PPLoginButton handles all auth flow
        loginButton = PPLoginButton.init()
    }
}
