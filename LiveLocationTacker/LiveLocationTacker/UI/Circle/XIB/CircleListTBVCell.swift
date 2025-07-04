//
//  CircleListTBVCell.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 18/11/24.
//

import UIKit

class CircleListTBVCell: UITableViewCell {

    @IBOutlet weak var lbl_membercount: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var main_view: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
