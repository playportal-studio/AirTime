//
//  LeadboardTableViewCell.swift
//  AirTime
//
//  Created by Lincoln Fraley on 10/19/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit

class LeadboardTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
