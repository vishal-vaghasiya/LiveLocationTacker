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
    var arrOfMember: [UserInfo] = []
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startCountdown()
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
        firebaseManager.fetchUserData { result, message in
            switch result {
            case .success(let userData):
                // Handle success here
                var sosMSG = DefaultManager.User.NAME
                sosMSG = sosMSG +  NSLocalizedString(" SOSPUSHCONTENT", comment: "") + " @"
                sosMSG = sosMSG +  String(userData.latitude) + "," + String(userData.longitude)
                
                let membersExceptMe = self.arrOfMember.filter { $0.phone != DefaultManager.User.PHONE }
                if membersExceptMe.count == 0 {
                    let vc = StoryboardScene.Circle.popupFailedSOS.instantiate()
                    vc.closePopup = { [weak self] in
                        self?.dismiss(animated: true)
                    }
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: false)
                    return
                }
                let phoneNumbers = membersExceptMe.map { $0.phone }
                // Optional: Sound alert
                AudioServicesPlaySystemSound(SystemSoundID(1005)) // Vibrate sound
                self.firebaseManager.fetchUsersFCMTokens(phoneNumbers: phoneNumbers) { result in
                    switch result {
                    case .success(let fcmTokens):
                        print("Fetched FCM Tokens: \(fcmTokens)")
                        for i in 0..<fcmTokens.count {
                            let token = fcmTokens[i]
                            let phoneNumer = phoneNumbers[i]
                            if token != "" {
                                self.firebaseManager.sendPushNotification(fcmToken: token, body: sosMSG)
                            } /*else {
                               if let phoneURL = URL(string: "tel://\(phoneNumer)"), UIApplication.shared.canOpenURL(phoneURL) {
                               UIApplication.shared.open(phoneURL)
                               }
                               }*/
                        }
                    case .failure(let error):
                        print("Error fetching FCM Tokens: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                // Handle error here
                print("Error: \(error.localizedDescription)")
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
