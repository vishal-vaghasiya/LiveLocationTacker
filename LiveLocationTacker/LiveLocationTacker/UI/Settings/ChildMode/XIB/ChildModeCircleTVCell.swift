//
//  ChildModeCircleTVCell.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 02/07/25.
//

import UIKit

class ChildModeCircleTVCell: UITableViewCell {
    
    @IBOutlet weak var ivArrow: UIImageView!
    @IBOutlet weak var btnDisable: UIButton!
    @IBOutlet weak var buttonView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
