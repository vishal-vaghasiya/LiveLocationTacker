//
//  MemberTVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit

class MemberTVCell: UITableViewCell {

    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var ivBattery: UIImageView!
    @IBOutlet weak var lblBattery: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var data: UserInfo! {
        didSet {
            let name = getFullName(firstName: data.firstName, lastName: data.lastName)
            ivProfile.setImage(urlString: data.profilePic, name: name, placeholderImage: Asset.iconSelectProfile.image, width: ivProfile.frame.width * 2, height: ivProfile.frame.height * 2)
            lblName.text = name
            
            let value = setUpBattery(batteryLevel: data.batteryLevel)
            lblBattery.text = value.0
            lblBattery.textColor = value.1
            ivBattery.image = value.2
            lblAddress.text = data.address
        }
    }
}
