//
//  SettingTVCell.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 30/06/25.
//

import UIKit

class SettingTVCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var img_view: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var img_arrow: UIImageView!
    @IBOutlet weak var lblChildModeLabel: UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var btnActive: UIButton!
    @IBOutlet weak var btnInActive: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
