//
//  SettingHeaderView.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 19/11/24.
//

import UIKit

class SettingHeaderView: UITableViewHeaderFooterView {

   
    @IBOutlet weak var profile_img: UIImageView!
    

    @IBOutlet weak var location_switch: UISwitch!
    @IBOutlet weak var battery_switch: UISwitch!
    @IBOutlet weak var notification_switch: UISwitch!
    @IBOutlet weak var camera_switch: UISwitch!
    @IBOutlet weak var motion_switch: UISwitch!
    
    @IBOutlet weak var lbl_number: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    var onTapProfileAction:(()->()) = { }
    var onTapSubscribeAction:(()->()) = { }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        profile_img.makeRounded()
        profile_img.contentMode = .scaleAspectFill
        
        location_switch.isOn = Constants.USERDEFAULTS.getLocationSharing()
        battery_switch.isOn = Constants.USERDEFAULTS.getBatterySharing()
        notification_switch.isOn = Constants.USERDEFAULTS.getNotificationSharing()
        camera_switch.isOn = Constants.USERDEFAULTS.getCameraSharing()
        motion_switch.isOn = Constants.USERDEFAULTS.getMotionSharing()
    }
    
    @IBAction func btnProfileAction(_ sender: UIButton) {
        onTapProfileAction()
    }
    
    @IBAction func btnPremuimAction(_ sender: UIButton) {
        onTapSubscribeAction()
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            Constants.USERDEFAULTS.saveLocationSharing(value: sender.isOn)
        case 1:
            Constants.USERDEFAULTS.saveBatterySharing(value: sender.isOn)
        case 2:
            Constants.USERDEFAULTS.saveNotificationSharing(value: sender.isOn)
        case 3:
            Constants.USERDEFAULTS.saveCameraSharing(value: sender.isOn)
        case 4:
            Constants.USERDEFAULTS.saveMotionSharing(value: sender.isOn)
        default:
            break
        }
    }
}
