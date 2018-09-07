//
//  HomeViewController.swift
//  AirTime
//
//  Created by Jett Black on 9/7/18.
//  Copyright © 2018 kontakt.io. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var profilePicGradient: UIView!
    @IBOutlet weak var profilePicBlack: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicGradient.layer.cornerRadius = profilePicGradient.frame.height / 2.0
        profilePicBlack.layer.cornerRadius = profilePicBlack.frame.height / 2.0
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.height / 2.0
        label.text = "@someUser | First Last"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
