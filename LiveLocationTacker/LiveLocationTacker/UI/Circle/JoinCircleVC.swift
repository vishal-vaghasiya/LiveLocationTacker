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
    var friendEnterCode = String()
    let firebaseManager = FirebaseManager.shared
    var groupCode = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lbl_name.text = DefaultManager.User.NAME
        lbl_number.text = DefaultManager.User.PHONE
        lbl_code.text = groupCode
        btnJoincircle.isEnabled = false
        profile_img.image = UIImage(data: DefaultManager.User.PROFILE_DATA ?? Data())
        
        otpTextField.otpDelegate = self
        otpTextField.otpCornerRaduis = 5
        otpTextField.otpBackgroundColor = .white.withAlphaComponent(0.15)
        otpTextField.otpFilledBorderWidth = 2
        otpTextField.otpFilledBorderColor = .btncolor
        otpTextField.otpFont = AppFont.semiBold(size: 18) ?? UIFont()
        otpTextField.otpTextColor = .btncolor
        otpTextField.otpFilledBackgroundColor = .white.withAlphaComponent(0.15)
        otpTextField.configure(with: 6)
        
        otpTextField.addTarget(self, action: #selector(otpDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func backClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShareCodeAction(_ sender: UIButton) {
        share(message: lbl_code.text ?? "", link: "")
    }
    
    @IBAction func btnJoinCircleAction(_ sender: UIButton) {
        showLoader(text: "Joing...")
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        firebaseManager.joinCircle(withCode: friendEnterCode,
                                circleId: groupCode,
                                batteryLevel: batteryLevel) { success in
            self.hideLoader()
            if success {
                print("Friend successfully joined the circle!")
                self.navigateToHome()
            } else {
                self.showAlert(title: "Enter code Incorrect !!", message: "Failed to join the circle.")
            }
        }
        
        /*firebaseManager.joinCircle(inviteCode: friendEnterCode) { success, message in
            if success {
                print("Friend successfully joined the circle!")
                self.navigateToHome()
            } else {
                self.showToastMessage(message)
            }
        }*/
        
    }
}


extension JoinCircleVC: AEOTPTextFieldDelegate {
    func didUserFinishEnter(the code: String) {
        friendEnterCode = code
        self.btnJoincircle.isEnabled = code.count == 6
    }
    
    @objc func otpDidChange(_ textField: UITextField) {
        let code = textField.text ?? ""
        self.btnJoincircle.isEnabled = code.count == 6
    }
}
