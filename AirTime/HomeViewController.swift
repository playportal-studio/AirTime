//
//  HomeViewController.swift
//  AirTime
//
//  Created by Jett Black on 9/7/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var profilePicGradient: GradientBkgndView!
    @IBOutlet weak var profilePicBlack: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var upperScoreLabel: UILabel!
    @IBOutlet weak var lowerScoreLabel: UILabel!
    
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
    }
    
    func rightButton() {
    
     self.performSegue(withIdentifier:"showSettings", sender: self)
    }
    
    func leftButton() {
        print("PRESSED: left")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
