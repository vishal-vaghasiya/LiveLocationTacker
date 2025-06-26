//
//  MemberTBVCell.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 16/11/24.
//

import UIKit

class MemberTBVCell: UITableViewCell {

    @IBOutlet weak var member_battery: UILabel!
    @IBOutlet weak var member_address: UILabel!
    @IBOutlet weak var member_name: UILabel!
    @IBOutlet weak var mrmber_image: UIImageView!
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
