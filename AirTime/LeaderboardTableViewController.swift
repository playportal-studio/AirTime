//
//  LeaderboardTableViewController.swift
//  AirTime
//
//  Created by Lincoln Fraley on 10/18/18.
//  Copyright © 2018 kontakt.io. All rights reserved.
//

import Foundation
import UIKit

class LeaderboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var leaderboardEntries: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        let service = PPLeaderboardService()
        service.getLeaderboard(page: 1, limit: 10, categories: "totalJumps") { [weak self] succeeded, response, responseObject in
            guard succeeded, let strongSelf = self else {
                return }
            if let json = responseObject as? [String: Any], let leaderboardEntries = json["docs"] as? [Any] {
                strongSelf.leaderboardEntries = leaderboardEntries
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
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
        if let entry = leaderboardEntries[indexPath.row] as? [String: Any],let user = entry["user"] as? [String: Any]
            , let rank = entry["rank"] as? Int
            , let score = entry["score"] as? Double, let handle = user["handle"] as? String
        {
            cell.handleLabel.text = handle
            cell.numberLabel.text = String(rank)
            cell.scoreLabel.text = String(score)
            
            print()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
