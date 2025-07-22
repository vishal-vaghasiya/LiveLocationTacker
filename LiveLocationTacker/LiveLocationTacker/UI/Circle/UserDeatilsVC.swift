//
//  UserDeatilsVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 18/11/24.
//

import UIKit

class UserDeatilsVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgBattery: UIImageView!
    @IBOutlet weak var lblBattery: UILabel!
    @IBOutlet weak var main_view: UIView!
    @IBOutlet weak var lbl_number: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_lastupdate: UILabel!
    @IBOutlet weak var lbl_address: UILabel!
    
    var userInfo = UserInfo(dictionary: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lbl_lastupdate.text = formatDate()
        lbl_address.text = userInfo.address//address
        lbl_name.text = userInfo.name //username
        lbl_number.text = userInfo.phone //usernumber
        self.imgProfile.setImage(urlString: userInfo.profilePic, name: userInfo.name, placeholderImage: Asset.iconDefaultProfile.image, width: self.imgProfile.frame.width * 2, height: self.imgProfile.frame.height * 2)
        self.setUpBattery(batteryLevel: userInfo.batteryLevel)
    }
    
    @IBAction func outerViewAction(_ sender: UIControl) {
        self.dismiss(animated: true)
    }
    
    func setUpBattery(batteryLevel: Int) {
        self.lblBattery.text = "\(batteryLevel)%"
        if batteryLevel >= 80 {
            self.lblBattery.textColor = .systemGreen
            self.imgBattery.image = Asset.battery.image
        } else if batteryLevel <= 20 {
            self.lblBattery.textColor = .systemRed
            self.imgBattery.image = Asset.batteryLow.image
        } else {
            self.lblBattery.textColor = .systemOrange
            self.imgBattery.image = Asset.batteryMid.image
        }
    }
}
