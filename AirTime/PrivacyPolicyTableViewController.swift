//
//  PrivacyPolicyTableViewController.swift
//  AirTime
//
//  Created by Joshua Paulsen on 9/10/18.
//  Copyright © 2018 kontakt.io. All rights reserved.
//

import Foundation
import UIKit

class PrivacyPolicyViewController : UITableViewController {
    
    
    @IBOutlet weak var notcell1: UITableViewCell!
    
    @IBOutlet weak var notcell2: UITableViewCell!
    
    @IBOutlet weak var notcell3: UITableViewCell!
    
    @IBOutlet weak var notcell4: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        notcell1.textLabel!.text = "placeHolder"
        
        notcell2.textLabel!.text = "placeHolder"
        
        notcell3.textLabel!.text = "placeHolder"
        
        notcell4.textLabel!.text = "placeHolder"
        
        self.tableView.tableFooterView = UIView()
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "What Information Is Collected"
        case 1:
            return "Why It Is Collected"
        case 2:
            return "With Whom It Is Shared"
        case 3:
            return "Contact Us"
        default :
            return "No Header"
        }
    }
}
