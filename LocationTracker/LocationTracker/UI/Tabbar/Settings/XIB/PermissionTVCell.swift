//
//  PermissionTVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit

class PermissionTVCell: UITableViewCell {

    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var batterySwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var cameraSwitch: UISwitch!
    @IBOutlet weak var motionSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        locationSwitch.isOn = DefaultManager.Permission.LOCATION
        batterySwitch.isOn = DefaultManager.Permission.BATTERY
        notificationSwitch.isOn = DefaultManager.Permission.NOTIFICATION
        cameraSwitch.isOn = DefaultManager.Permission.CAMERA
        motionSwitch.isOn = DefaultManager.Permission.MOTION
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchClick(_ sender: UISwitch) {
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
