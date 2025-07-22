//
//  MemberTBVCell.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 16/11/24.
//

import UIKit

class MemberTBVCell: UITableViewCell {

    @IBOutlet weak var imgBattery: UIImageView!
    @IBOutlet weak var member_battery: UILabel!
    @IBOutlet weak var member_address: UILabel!
    @IBOutlet weak var member_name: UILabel!
    @IBOutlet weak var mrmber_image: UIImageView!
    @IBOutlet weak var main_view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpBattery(batteryLevel: Int) {
        self.member_battery.text = "\(batteryLevel)%"
        if batteryLevel >= 80 {
            self.member_battery.textColor = .systemGreen
            self.imgBattery.image = Asset.battery.image
        } else if batteryLevel <= 20 {
            self.member_battery.textColor = .systemRed
            self.imgBattery.image = Asset.batteryLow.image
        } else {
            self.member_battery.textColor = .systemOrange
            self.imgBattery.image = Asset.batteryMid.image
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
