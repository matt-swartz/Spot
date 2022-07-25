//
//  MessageCell.swift
//  Spot
//
//  Created by rachel.okeefe on 12/1/21.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(message: String, name: String) {

        messageLabel.text = "\(message)"
        nameLabel.text = "\(name)"
    }
}
