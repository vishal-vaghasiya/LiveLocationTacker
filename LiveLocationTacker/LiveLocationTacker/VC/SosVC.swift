//
//  SosVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 24/12/24.
//

import UIKit
import FirebaseDatabase

class SosVC: UIViewController {

    @IBOutlet weak var lbl_timer: UILabel!
    var sosTime = 10
    var timer: Timer?
    let groupManager = FirebaseManager()
    var memberList:[String:Any] = [:]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let lastLocation = selectedGroupsnapSort?.childSnapshot(forPath: "members").childSnapshot(forPath: Constants.USERDEFAULTS.getCurrentuserNumber()).value as? [String:Any] else { return }
        
        //send sos to friends
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.sosTime < 1{
                
                var sosMSG = Constants.USERDEFAULTS.getCurrentuserName()
                sosMSG = sosMSG +  NSLocalizedString(" SOSPUSHCONTENT", comment: "") + " @"
                sosMSG = sosMSG +  String(lastLocation["latitude"]  as? Double ?? 0) + "," + String(lastLocation["longitude"]  as? Double ?? 0)
                
                if let memberNumber = Array(self.memberList.keys.sorted()) as? [String] {
                    
                    memberNumber.forEach { phoneNumber in
                      
                        if phoneNumber != Constants.USERDEFAULTS.getCurrentuserNumber() {
                            self.groupManager.ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: phoneNumber).observeSingleEvent(of: .value) { snapshot in
                                if snapshot.exists() {
                                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
                                        if let circleData = snap.value as? [String: Any],
                                           let fcmToken = circleData["fcmtoken"] as? String {
                                            print("sosMSG ==> \(sosMSG)")
                                            self.groupManager.sendPushNotification(fcmToken: fcmToken, body: sosMSG)
                                        }
                                        else {
                                            print("FCM token not found for admin \(phoneNumber).")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                print("SOS timeer CALLED")
                self.sosTime = 10
                timer.invalidate()
                self.dismiss(animated: true)
            }
            self.sosTime = self.sosTime - 1
            self.lbl_timer.text = "\(self.sosTime)"
        }
    }
    

    @IBAction func btnStopAction(_ sender: UIButton) {
        cancelSOS()
    }

    @objc func cancelSOS(){
        timer?.invalidate()
        timer = nil
        self.dismiss(animated: true)
    }
}
