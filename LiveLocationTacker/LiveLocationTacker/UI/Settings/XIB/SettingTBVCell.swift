//
//  SettingTBVCell.swift
//  GBWhatsApp
//
//  Created by DREAMWORLD on 25/10/24.
//

import UIKit

class SettingTBVCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var img_view: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var img_arrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
