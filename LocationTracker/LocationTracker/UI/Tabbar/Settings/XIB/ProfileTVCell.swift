//
//  ProfileTVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit

class ProfileTVCell: UITableViewCell {
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ivProfile.setImage(urlString: DefaultManager.User.PROFILE_PIC, name: DefaultManager.User.NAME, placeholderImage: Asset.iconSelectProfile.image, width: ivProfile.frame.width * 2, height: ivProfile.frame.height * 2)
        lblName.text = DefaultManager.User.NAME
        lblMobile.text = DefaultManager.User.PHONE
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
