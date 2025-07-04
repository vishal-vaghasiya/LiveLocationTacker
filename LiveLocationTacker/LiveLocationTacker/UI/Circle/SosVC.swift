//
//  SosVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 24/12/24.
//

import UIKit
import FirebaseDatabase
import AudioToolbox

class SosVC: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var lblCountdown: UILabel!
    var sosTime = 10
    var timer: Timer?
    private var countdown = 5
    
    let firebaseManager = FirebaseManager.shared
    var memberList:[String:Any] = [:]
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startCountdown()
        //        guard let lastLocation = selectedGroupsnapSort?.childSnapshot(forPath: "members").childSnapshot(forPath: Constants.USERDEFAULTS.getCurrentuserNumber()).value as? [String:Any] else { return }
        
        //send sos to friends
        //        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        //            if self.sosTime < 1{
        //
        //                var sosMSG = Constants.USERDEFAULTS.getCurrentuserName()
        //                sosMSG = sosMSG +  NSLocalizedString(" SOSPUSHCONTENT", comment: "") + " @"
        //                sosMSG = sosMSG +  String(lastLocation["latitude"]  as? Double ?? 0) + "," + String(lastLocation["longitude"]  as? Double ?? 0)
        //
        //                if let memberNumber = Array(self.memberList.keys.sorted()) as? [String] {
        //
        //                    memberNumber.forEach { phoneNumber in
        //
        //                        if phoneNumber != Constants.USERDEFAULTS.getCurrentuserNumber() {
        //                            self.firebaseManager.ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: phoneNumber).observeSingleEvent(of: .value) { snapshot in
        //                                if snapshot.exists() {
        //                                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
        //                                        if let circleData = snap.value as? [String: Any],
        //                                           let fcmToken = circleData["fcmtoken"] as? String {
        //                                            print("sosMSG ==> \(sosMSG)")
        //                                            self.firebaseManager.sendPushNotification(fcmToken: fcmToken, body: sosMSG)
        //                                        }
        //                                        else {
        //                                            print("FCM token not found for admin \(phoneNumber).")
        //                                        }
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }
        //                }
        //                print("SOS timeer CALLED")
        //                self.sosTime = 10
        //                timer.invalidate()
        //                self.dismiss(animated: true)
        //            }
        //            self.sosTime = self.sosTime - 1
        //            self.lbl_timer.text = "\(self.sosTime)"
        //        }
    }
    
    // MARK: - UI SETUP
    private func startCountdown() {
        countdown = 10
        lblCountdown.text = "\(countdown)"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else { return }
            self.countdown -= 1
            self.lblCountdown.text = "\(self.countdown)"
            if self.countdown <= 0 {
                t.invalidate()
                self.triggerSOS()
            }
        }
    }
    
    // MARK: - SOS Logic
    private func triggerSOS() {
        lblCountdown.text = ""
        guard let lastLocation = selectedGroupsnapSort?.childSnapshot(forPath: "members").childSnapshot(forPath: DefaultManager.User.PHONE).value as? [String:Any] else { return }
        
        var sosMSG = DefaultManager.User.NAME
        sosMSG = sosMSG +  NSLocalizedString(" SOSPUSHCONTENT", comment: "") + " @"
        sosMSG = sosMSG +  String(lastLocation["latitude"]  as? Double ?? 0) + "," + String(lastLocation["longitude"]  as? Double ?? 0)
        
        if let memberNumber = Array(self.memberList.keys.sorted()) as? [String] {
            let filterObject = memberNumber.filter { $0 != DefaultManager.User.PHONE }
            if filterObject.count == 0 {
                let vc = StoryboardScene.Circle.popupFailedSOS.instantiate()
                vc.closePopup = { [weak self] in
                    self?.dismiss(animated: true)
                }
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false)
                return
            }
            // Optional: Sound alert
            AudioServicesPlaySystemSound(SystemSoundID(1005)) // Vibrate sound
            memberNumber.forEach { phoneNumber in
                if phoneNumber != DefaultManager.User.PHONE {
                    self.firebaseManager.ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: phoneNumber).observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists() {
                            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                                if let circleData = snap.value as? [String: Any],
                                   let fcmToken = circleData["fcmtoken"] as? String {
                                    print("sosMSG ==> \(sosMSG)")
                                    self.firebaseManager.sendPushNotification(fcmToken: fcmToken, body: sosMSG)
                                }
                                else {
                                    print("FCM token not found for admin \(phoneNumber).")
                                    // Optionally trigger a phone call (requires user confirmation)
                                    if let phoneURL = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
                                        UIApplication.shared.open(phoneURL)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        self.dismiss(animated: true)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func btnStopAction(_ sender: UIButton) {
        timer?.invalidate()
        timer = nil
        self.dismiss(animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
    
    
    
}
