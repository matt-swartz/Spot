//
//  OpenReportCell.swift
//  Spot
//
//  Created by Matthew Swartz on 11/16/21.
//

import UIKit

class OpenReportCell: UITableViewCell {

    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var lastLocationLabel: UILabel!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var approachLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
