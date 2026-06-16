//
//  PopupRequestToDisable.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 11/08/25.
//

import UIKit

class PopupRequestToDisable: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var ivCircleImage: UIImageView!
    @IBOutlet weak var lblCircleName: UILabel!
    
    @IBOutlet weak var lblIOwner: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    // MARK: - PROPERTY
    let firebaseManager = FirebaseManager.shared
    var cirlceInfo = CircleInfo()
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        firebaseManager.getMyCircle { success, message, data in
            let filteredList = data.filter { $0.code == DefaultManager.User.CHILD_MODE_CODE }
            if filteredList.count > 0 {
                self.cirlceInfo = filteredList[0]
                self.lblCircleName.text = self.cirlceInfo.name
            }
        }
    }

    func setupLocalization() {
        self.btnSend.setTitle(L10n.send, for: .normal)
        self.btnCancel.setTitle(L10n.cancel, for: .normal)
        self.lblIOwner.text = L10n.circleOwner
        self.lblTitle.attributedText = L10n.sendRequestRoDisableChildMode.lineSpacing(noOfLine: 3, alignment: .left)
        self.lblSubTitle.attributedText = L10n.theCircleOwnerWillGetANotificationToTurnItOffForYou.lineSpacing(noOfLine: 3, alignment: .left)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func cancelClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .setting_childmode_diable_click_cancel)
        self.dismiss(animated: false)
    }
    
    @IBAction func clickSend(_ sender: UIButton) {
        Loader.show("Requesting ...")
        let ownerPhone = self.cirlceInfo.ownerPhone
        let code = self.cirlceInfo.code
        FirebaseManager.shared.logAnalyticsEvent(name: .setting_childmode_diable_click_send)
        self.firebaseManager.fetchUserData(phoneNumber: ownerPhone) { result in
            Loader.hide()
            switch result {
            case .success(let user):
                if user.fcmtoken != "" {
                    let message = "\(DefaultManager.User.NAME) has requested to turn off Child Mode.Tap and choose the response."
                    NotificationManager.shared.sendPushNotification(type: .disableChildMode, fcmToken: user.fcmtoken, body: message, code: code) { success, message in
                        DispatchQueue.main.async {
                            showToast(message: message)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            self.dismiss(animated: false)
                        })
                    }
                } else {
                    self.dismiss(animated: false)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
