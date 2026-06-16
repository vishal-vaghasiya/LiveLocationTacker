//
//  SOSCallingVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit
import AudioToolbox

class SOSCallingVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblSosTitle: UILabel!
    @IBOutlet weak var imgCountBG: UIImageView!
    @IBOutlet weak var lblCountdown: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnStop: UIButton!
    
    // MARK: - PROPERTY
    var onDismissed: (() -> Void)?
    var onSentEvent: ((Bool) -> ())?
    
    var timer: Timer?
    private var countdown = Int()
    var arrOfMember: [UserInfo] = []
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startCountdown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    
    func setupLocalization() {
        self.lblSosTitle.text = L10n.sosCalling + "..."
        self.lblDescription.text = L10n.countdownLocationShare
        self.btnStop.setTitle(L10n.stop, for: .normal)

    }
    
    private func startCountdown() {
        self.imgCountBG.rotated(time: 1.5, isContinuous: true)
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
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func btnStopAction(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .sos_click_stop)
        timer?.invalidate()
        timer = nil
        self.dismiss(animated: true) {
            self.onDismissed?()
        }
    }
    
    // MARK: - OTHER
    private func triggerSOS() {
        lblCountdown.text = ""
        FirebaseManager.shared.fetchUserData { result, message in
            switch result {
            case .success(let userData):
                var sosMSG = DefaultManager.User.NAME
                sosMSG = sosMSG +  NSLocalizedString(" SOSPUSHCONTENT", comment: "") + " @"
                sosMSG = sosMSG +  String(userData.latitude) + "," + String(userData.longitude)
                
                let membersExceptMe = self.arrOfMember.filter { $0.phone != DefaultManager.User.PHONE }
                if membersExceptMe.count == 0 {
//                    let vc = StoryboardScene.Circle.popupFailedSOS.instantiate()
//                    vc.modalPresentationStyle = .overFullScreen
//                    vc.onDismissed = {
//                        self.dismiss(animated: true) {
//                            self.onDismissed?()
//                        }
//                    }
//                    self.present(vc, animated: false)
                    self.dismiss(animated: true) {
                        self.onDismissed?()
                        self.onSentEvent?(false)
                    }
                    return
                }
                let phoneNumbers = membersExceptMe.map { $0.phone }
                AudioServicesPlaySystemSound(SystemSoundID(1005)) // Vibrate sound
                FirebaseManager.shared.fetchUsersFCMTokens(phoneNumbers: phoneNumbers) { result in
                    switch result {
                    case .success(let fcmTokens):
                        let dispatchGroup = DispatchGroup()
                        for token in fcmTokens where !token.isEmpty {
                            dispatchGroup.enter()
                            NotificationManager.shared.sendPushNotification(type: .sos, fcmToken: token, body: sosMSG) { success, message in
                                dispatchGroup.leave()
                            }
                        }
                        dispatchGroup.notify(queue: .main) {
                            print("All push notifications sent.")
                            self.dismiss(animated: true, completion:  {
                                self.onDismissed?()
                                self.onSentEvent?(true)
                            })
                        }
                    case .failure(let error):
                        print("Error fetching FCM Tokens: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
