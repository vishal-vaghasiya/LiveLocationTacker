//
//  PermissionVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 16/11/24.
//

import UIKit
import CoreLocation
import AVFoundation


class PermissionVC: UIViewController {

    @IBOutlet weak var btnLetsStart: UIButton!
    @IBOutlet var shadow_view: [UIView]!

    @IBOutlet weak var location_switch: UISwitch!
    @IBOutlet weak var camera_switch: UISwitch!
    @IBOutlet weak var notification_switch: UISwitch!
    @IBOutlet weak var motion_switch: UISwitch!
    var locationManager: CLLocationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnLetsStart.setButtonTitleAndFunctionality("Continue"/*"Get Started"*/)
//        shadow_view.forEach({ $0.addLightShadow() })
        checkPermission()
        
        locationManager.delegate = self
    }
    
    func checkPermission(){
        location_switch.isOn = PermissionManager.checkLocationPermission()
        notification_switch.isOn = PermissionManager.checkNotificationPermission()
        motion_switch.isOn = PermissionManager.checkMotionPermission()
        camera_switch.isOn = PermissionManager.checkCameraPermission()
    }

    @IBAction func switchValueChangeAction(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            self.requestLocationPermission { isGranted in
                if isGranted == false {
                    self.showAlertPermission(title: "", message: "Please go to setting and enable Location permission.")
                    sender.isOn = false
                }
                else{
                    sender.isOn = true
                }
            }
        case 1:
            PermissionManager.requestCameraPermission { isGranted in
                sender.isOn = isGranted
                if !isGranted {
                    self.showAlertPermission(title: "", message: "Please go to Settings and enable Camera permission.")
                }
            }
        case 2:
            PermissionManager.requestNotificationPermission { isGranted in
                sender.isOn = isGranted
                if !isGranted {
                    self.showAlertPermission(title: "", message: "Please go to setting and enable Notification permission.")
                }
            }
        case 3:
            PermissionManager.requestMotionPermission { isGranted in
                if isGranted == false {
                    self.showAlertPermission(title: "", message: "Please go to setting and enable Motion Activity permission.")
                    sender.isOn = false
                }
                else{
                    sender.isOn = true
                }
            }
        default:
            break
        }
    }
    
    @IBAction func btnLetsStartAction(_ sender: UIButton) {
        if location_switch.isOn && camera_switch.isOn && notification_switch.isOn && motion_switch.isOn {
            let vc = StoryboardScene.Main.loginMobilenumberVC.instantiate()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            showAlert(title: "", message: "Please grant all premission")
        }
    }
}


//MARK: - LOcation Permission

extension PermissionVC : CLLocationManagerDelegate {
    
    func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        let currentStatus = CLLocationManager.authorizationStatus()
        
        switch currentStatus {
        case .notDetermined:
            // Request location access
            if #available(iOS 13.4, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.requestAlwaysAuthorization()
            }
        case .authorizedAlways, .authorizedWhenInUse:
            completion(true)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - Camera Permssion
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            case .authorized:
                completion(true)
            case .denied, .restricted:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            location_switch.isOn = true
        case .denied, .restricted:
            self.showAlertPermission(title: "", message: "Please go to setting and enable Location permission.")
            location_switch.isOn = false
        default:
            break
        }
    }
    
}
