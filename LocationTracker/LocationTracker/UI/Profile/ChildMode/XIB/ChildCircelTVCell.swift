//
//  ChildCircelTVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 11/08/25.
//

import UIKit

class ChildCircelTVCell: UITableViewCell {

    @IBOutlet weak var lblCircleName: UILabel!
    @IBOutlet weak var ivArrow: UIImageView!
    @IBOutlet weak var ivCircle: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblMemberCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var data: CircleInfo! {
        didSet {
            lblCircleName.text = data.name
        }
    }
    
}
