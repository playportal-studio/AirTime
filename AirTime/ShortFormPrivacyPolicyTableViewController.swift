//
//  ShortFormPrivacyPolicyTableViewController.swift
//  AirTime
//
//  Created by Lincoln Fraley on 10/18/18.
//  Copyright © 2018 kontakt.io. All rights reserved.
//

import Foundation
import UIKit

class ShortFormPrivacyPolicyTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return 5
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shortFormPrivacyPolicyTableViewCell", for: indexPath)
        var text: String?
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            text = "None"
        case (1, 0):
            text = "N/A"
        case (2, 0):
            text = "N/A"
        case (3, 0):
            text = "your-email@email.com"
        case (3, 1):
            text = "Your Company"
        case (3, 2):
            text = "Your address"
        case (3, 3):
            text = "Your city"
        case (3, 4):
            text = "Your zipcode"
        default:
            break
        }
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "WHAT INFORMATION IS COLLECTED"
        case 1:
            return "WHY IT IS COLLECTED"
        case 2:
            return "WITH WHOM IT IS SHARED"
        case 3:
            return "Contact Us"
        default:
            return nil
        }
    }
}
