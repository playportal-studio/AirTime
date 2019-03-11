//
//  LeaderboardTableViewController.swift
//  AirTime
//
//  Created by Lincoln Fraley on 10/18/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import Foundation
import UIKit
import PPSDK_Swift
import SwiftOverlays

class LeaderboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var leaderboardEntries: [PlayPortalLeaderboardEntry] = []
    
    var user: PlayPortalProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        if user.anonymous {
            showTextOverlay("Login to access this feature!")
        } else {
            tableView.delegate = self
            tableView.dataSource = self
            
            PlayPortalLeaderboard.shared.getLeaderboard(forCategories: ["totalJumps"]) { [weak self] error, leaderboardEntries in
                guard let self = self else { return }
                if let error = error {
                    print("Error getting leaderboard entries: \(error)")
                } else if let leaderboardEntries = leaderboardEntries {
                    self.leaderboardEntries = leaderboardEntries
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        removeAllOverlays()
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardTableViewCell", for: indexPath) as? LeadboardTableViewCell else {
            return UITableViewCell()
        }
        let entry = leaderboardEntries[indexPath.row]
        cell.handleLabel.text = entry.user.handle
        cell.numberLabel.text = String(entry.rank)
        cell.scoreLabel.text = String(entry.score)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
