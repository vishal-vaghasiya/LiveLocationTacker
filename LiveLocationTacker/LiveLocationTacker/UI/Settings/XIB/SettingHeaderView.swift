//
//  SettingHeaderView.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 19/11/24.
//

import UIKit

class SettingHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var permissionView: UIView!
    
   
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
        
        location_switch.isOn = DefaultManager.Permission.LOCATION
        battery_switch.isOn = DefaultManager.Permission.BATTERY
        notification_switch.isOn = DefaultManager.Permission.NOTIFICATION
        camera_switch.isOn = DefaultManager.Permission.CAMERA
        motion_switch.isOn = DefaultManager.Permission.MOTION
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
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .setting_locationsharing_enable : .setting_locationsharing_diable)
            DefaultManager.Permission.LOCATION = sender.isOn
        case 1:
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .setting_batterylevalsharing_enable : .setting_betterylevalsharing_diable)
            DefaultManager.Permission.BATTERY = sender.isOn
        case 2:
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .setting_notification_enable : .setting_notification_diable)
            DefaultManager.Permission.NOTIFICATION = sender.isOn
        case 3:
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .setting_accesscamera_enable : .setting_accesscamera_disable)
            DefaultManager.Permission.CAMERA = sender.isOn
        case 4:
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .setting_motion_enable : .setting_motion_disable)
            DefaultManager.Permission.MOTION = sender.isOn
        default:
            break
        }
    }
}
