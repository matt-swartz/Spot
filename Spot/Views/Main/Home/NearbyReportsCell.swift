//
//  NearbyReportsCell.swift
//  Spot
//
//  Created by rachel.okeefe on 12/7/21.
//

import UIKit

class NearbyReportsCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageLink: UIImageView!
    @IBOutlet weak var lastLocationLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
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
