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
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCircleName: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var ivProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var data: ChildModeCircleInfo! {
        didSet {
            lblCircleName.text = data.circleName
            lblName.text = data.childName
            ivProfile.setImage(urlString: data.childProfile, name: data.childName, placeholderImage: Asset.iconDefaultProfile.image, width: ivProfile.frame.width * 2, height: ivProfile.frame.height * 2)
        }
    }
}
