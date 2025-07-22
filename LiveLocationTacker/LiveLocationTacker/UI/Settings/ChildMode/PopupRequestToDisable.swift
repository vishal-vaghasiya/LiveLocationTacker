//
//  PopupRequestToDisable.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 02/07/25.
//

import UIKit

class PopupRequestToDisable: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var ivCircleImage: UIImageView!
    @IBOutlet weak var lblCircleName: UILabel!
    
    // MARK: - PROPERTY
    let firebaseManager = FirebaseManager.shared
    var cirlceInfo = CircleInfo()
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func sendButtonClick(_ sender: UIButton) {
        showLoader(text: "Requesting ...")
        let ownerPhone = self.cirlceInfo.ownerPhone
        let code = self.cirlceInfo.code
        FirebaseManager.shared.logAnalyticsEvent(name: .setting_childmode_diable_click_send)
        firebaseManager.fetchUserData(phoneNumber: ownerPhone) { result in
            hideLoader()
            switch result {
            case .success(let user):
                if user.fcmtoken != "" {
                    let message = "\(DefaultManager.User.NAME) has requested to turn off Child Mode.Tap and choose the response."
                    FCMNotificationManager.shared.sendPushNotification(type: .disableChildMode, fcmToken: user.fcmtoken, body: message, code: code) { success, message in
                        showToastMessage(message)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.dismiss(animated: false)
                    })
                } else {
                    self.dismiss(animated: false)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .setting_childmode_diable_click_cancel)
        self.dismiss(animated: false)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
