//
//  SettingsTableTableViewController.swift
//  AirTime
//
//  Created by Jett Black on 9/7/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit

class SettingsTableTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: PPUserObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let accountType = user.get(key: "accountType") else { return 0 }
            if accountType == "Kid" {
                return 2
            } else {
                return 4
            }
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath)
        let accountType = user.get(key: "accountType")!
        var text: String?
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            text = "Contact Us"
        case (0, 1):
            text = accountType == "Parent" ? "Terms of Service" : "Short Form Privacy Policy"
        case (0, 2):
            text = "Privacy Policy"
        case (0, 3):
            text = "Short Form Privacy Policy"
        case (1, 0):
            text = "Manage playPORTAL Account"
        case (2, 0):
            text = "Logout"
        default:
            break
        }
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            //  Open mail app to allow user feedback
            let email = "your-email@email.com"
            guard let url = URL(string: "mailto:\(email)") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case (0, 1):
            //  This will open a link to your terms of service
            //  However, this is disabled for kids as it's an outside link and will be the short form privacy policy
            //  from the kid's perspective
            guard let accountType = user.get(key: "accountType") else { return }
            if accountType == "Kid" {
                guard let shortFormPrivacyPolicy = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "shortFormPrivacyPolicy") as? ShortFormPrivacyPolicyTableViewController else { return }
                present(shortFormPrivacyPolicy, animated: true, completion: nil)
            } else {
                guard let url = URL(string: "http://www.dynepic.com/pages/terms-of-service") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case (0, 2):
            guard user.get(key: "accountType") == "Parent" else { return }
            guard let url = URL(string: "http://www.dynepic.com/pages/privacy-policy") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case (0, 3):
            guard let shortFormPrivacyPolicy = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "shortFormPrivacyPolicy") as? ShortFormPrivacyPolicyTableViewController else { return }
            present(shortFormPrivacyPolicy, animated: true, completion: nil)
        case (1, 0):
            Utils.openOrDownloadPlayPortal()
        case (2, 0):
            PPManager.sharedInstance.logout()
            let sb:UIStoryboard = UIStoryboard.init(name:"Main", bundle:nil)
            guard let rvc:UIViewController = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            let vc:LoginViewController = sb.instantiateViewController(withIdentifier:"LoginViewController") as! LoginViewController
            vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal;
            if let cvc = getCurrentViewController(rvc) {
                print("userListener NOT authd current VC: \(cvc )" );
                cvc.present(vc, animated:true, completion:nil)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "PRIVACY"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
