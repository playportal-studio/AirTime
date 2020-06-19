//
//  LoginViewController.swift
//  AirTime
//
//  Created by Gary J. Baldwin on 9/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit
import PPSDK_Swift
import SwiftOverlays

class LoginViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var continueAsGuestButton: UIButton!
    @IBOutlet weak var loginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.sizeToFit()
        titleLabel.transform = titleLabel.transform.rotated(by: CGFloat(-(Double.pi / 6)))
        continueAsGuestButton.backgroundColor = .clear
        continueAsGuestButton.layer.cornerRadius = continueAsGuestButton.frame.height / 2
        continueAsGuestButton.layer.borderWidth = 1
        continueAsGuestButton.layer.borderColor = UIColor.airtimeColors.yellow.cgColor
        
        
        //PPLoginButton handles all auth flow
        let loginButton = PlayPortalLoginButton(from: self)
        loginButton.center = CGPoint(x: loginView.bounds.size.width  / 2,
                                     y: loginView.bounds.size.height / 2)
        loginView.addSubview(loginButton)
    }
    
    @IBAction func continueAsGuestTapped(_ sender: UIButton) {
        showWaitOverlay()
        PlayPortalUser.shared.createAnonymousUser(clientId: clientId, dateOfBirth: "02/01/1993") { [weak self] error, userProfile in
            defer { self?.removeAllOverlays() }
            if let error = error {
                print("error signing in as guest: \(error)")
            } else if let userProfile = userProfile {
                guard let home = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home" ) as? HomeViewController else { return }
                home.user = userProfile
                self?.present(home, animated: true, completion: nil)
            } else {
                print("unknown error")
            }
        }
    }
}
