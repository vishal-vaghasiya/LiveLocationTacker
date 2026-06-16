//
//  ProximityTVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 13/08/25.
//

import UIKit
import CoreLocation

class ProximityTVCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var ivIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var data: ProximityAlert! {
        didSet {
            lblName.text = data.name ?? "No Name"
            lblAddress.text = data.location ?? "No Address"
            ivIcon.image = getPin(type: "\(data.type)").1
        }
    }
    
}
