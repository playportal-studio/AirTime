//
//  SettingsTableViewController.swift
//  AirTime
//
//  Created by Gary J. Baldwin on 9/21/18.
//  Copyright © 2018 Gary J. Baldwin. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var cell1Settings: UITableViewCell!
    @IBOutlet weak var cell2Settings: UITableViewCell!
    @IBOutlet weak var cell1Header: UITableViewCell!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        cell1Settings.textLabel!.text = "Privacy Policy"
//        cell2Settings.textLabel!.text = "Manage playPORTAL Account"
        self.tableView.tableFooterView = UIView()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Privacy"
        case 1:
            return "Account"
        default :
            return "No Header"
        }
    }
    
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section: NSInteger) -> NSInteger {
        return 1
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "settingscell", for:indexPath)

            cell.textLabel?.text = "some text"
        return cell;
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case (0,0) :
            self.performSegue(withIdentifier: "privacyPolicy", sender: self)
            self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
            print("Privacy Policy")
        case (1,0) :
            self.tableView.deselectRow(at: IndexPath(row: 0, section: 1), animated: true)
            print("Manage Account")
            Utils.openOrDownloadPlayPortal()
        default:
            print("Default")
            
        }
    }
    
    
}
