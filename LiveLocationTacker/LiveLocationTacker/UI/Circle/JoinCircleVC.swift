//
//  JoinCircleVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 16/11/24.
//

import UIKit
import AEOTPTextField


class JoinCircleVC: UIViewController {
    
    @IBOutlet weak var profile_img: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_number: UILabel!
    @IBOutlet weak var lbl_code: UILabel!
    @IBOutlet weak var btnJoincircle: UIEnableDisable!
    @IBOutlet weak var otpTextField: AEOTPTextField!
    
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIView!
    
    var joinCircleCode = String()
    let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_name.text = DefaultManager.User.NAME
        lbl_number.text = DefaultManager.User.PHONE
        lbl_code.text = DefaultManager.Cirlce.CURRENT_CODE
        btnJoincircle.isEnabled = false
        //profile_img.image = UIImage(data: DefaultManager.User.PROFILE_DATA ?? Data())
        
        let profile = DefaultManager.User.PROFILE_PIC
        profile_img.setImage(urlString: profile, name: DefaultManager.User.NAME, placeholderImage: Asset.iconDefaultProfile.image, width: profile_img.frame.width * 2, height: profile_img.frame.height * 2)
        
        otpTextField.otpDelegate = self
        otpTextField.otpCornerRaduis = 5
        otpTextField.otpBackgroundColor = .white.withAlphaComponent(0.15)
        otpTextField.otpFilledBorderWidth = 2
        otpTextField.otpFilledBorderColor = .btncolor
        otpTextField.otpFont = FontFamily.Poppins.semiBold.font(size: 18)
        otpTextField.otpTextColor = .btncolor
        otpTextField.otpFilledBackgroundColor = .white.withAlphaComponent(0.15)
        otpTextField.configure(with: 6)
        
        otpTextField.addTarget(self, action: #selector(otpDidChange(_:)), for: .editingChanged)
        self.setBannerAds()
    }
    
    // MARK: - Setup Ads
    func setBannerAds() {
        AdManager.shared.loadBannerAd(in: self.bannerView, rootViewController: self) { isShow in
            if isShow {
                UIView.animate(withDuration: 0.5) {
                    self.contBannerHeight.constant = 50
                    self.view.layoutIfNeeded()
                }
            } else {
                self.contBannerHeight.constant = 0
            }
        }
    }
    
    @IBAction func clickEnterOtp(_ sender: UITextField) {
        FirebaseManager.shared.logAnalyticsEvent(name: .addmember_click_addinvitecode)
    }
    
    @IBAction func backClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShareCodeAction(_ sender: UIButton) {
        share(message: lbl_code.text ?? "", link: "")
    }
    
    @IBAction func btnJoinCircleAction(_ sender: UIButton) {
        showLoader(text: "Joing...")
        FirebaseManager.shared.logAnalyticsEvent(name: .addmember_click_joincircle)
        //        UIDevice.current.isBatteryMonitoringEnabled = true
        //        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        //        firebaseManager.joinCircle(withCode: friendEnterCode,
        //                                circleId: groupCode,
        //                                batteryLevel: batteryLevel) { success in
        //            hideLoader()
        //            if success {
        //                print("Friend successfully joined the circle!")
        //                self.navigateToHome()
        //            } else {
        //                self.showAlert(title: "Enter code Incorrect !!", message: "Failed to join the circle.")
        //            }
        //        }
        
        firebaseManager.joinCircle(inviteCode: joinCircleCode) { success, message in
            hideLoader()
            if success {
                print("Friend successfully joined the circle!")
                self.navigateToHome()
            } else {
                showToastMessage(message)
            }
        }
        
    }
}

extension JoinCircleVC: AEOTPTextFieldDelegate {
    func didUserFinishEnter(the code: String) {
        joinCircleCode = code
        self.btnJoincircle.isEnabled = code.count == 6
    }
    
    @objc func otpDidChange(_ textField: UITextField) {
        let code = textField.text ?? ""
        self.btnJoincircle.isEnabled = code.count == 6
    }
}
