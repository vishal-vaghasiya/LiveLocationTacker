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
            DefaultManager.Permission.LOCATION = sender.isOn
        case 1:
            DefaultManager.Permission.BATTERY = sender.isOn
        case 2:
            DefaultManager.Permission.NOTIFICATION = sender.isOn
        case 3:
            DefaultManager.Permission.CAMERA = sender.isOn
        case 4:
            DefaultManager.Permission.MOTION = sender.isOn
        default:
            break
        }
    }
}
