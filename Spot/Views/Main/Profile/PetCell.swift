//
//  PetCell.swift
//  Spot
//
//  Created by Matthew Swartz on 11/5/21.
//

import UIKit

class PetCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var petTypeLabel: UILabel!
    @IBOutlet weak var petImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
