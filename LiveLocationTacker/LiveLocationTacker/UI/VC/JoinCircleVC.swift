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
    @IBOutlet weak var btnJoincircle: UIButton!
    @IBOutlet weak var otpTextField: AEOTPTextField!
    var friendEnterCode = String()
    let groupManager = FirebaseManager()
    var groupCode = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lbl_name.text = Constants.USERDEFAULTS.getCurrentuserName()
        lbl_number.text = Constants.USERDEFAULTS.getCurrentuserNumber()
        lbl_code.text = groupCode
        
        btnJoincircle.setButtonTitleAndFunctionality("Join Circle")
        profile_img.image = UIImage(data: Constants.USERDEFAULTS.getProfileImage() ?? Data())
        profile_img.makeRounded()
        
        otpTextField.otpDelegate = self
        otpTextField.otpCornerRaduis = 5
        otpTextField.otpBackgroundColor = .white
        otpTextField.otpFilledBorderWidth = 2
        otpTextField.otpFilledBorderColor = .btncolor
        otpTextField.otpFont = AppFont.semiBold(size: 18) ?? UIFont()
        otpTextField.otpTextColor = .btncolor
        otpTextField.otpFilledBackgroundColor = .white
        otpTextField.configure(with: 6)
    }
    
    @IBAction func btnShareCodeAction(_ sender: UIButton) {
        share(message: lbl_code.text ?? "", link: "")
    }
    
    @IBAction func btnJoinCircleAction(_ sender: UIButton) {
        showLoader(text: "Joing...")
        print("friendEnterCode ==> \(friendEnterCode)")
        print("groupCode ==> \(groupCode)")
        
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        
        groupManager.joinCircle(withCode: friendEnterCode,
                                circleId: groupCode,
                                batteryLevel: batteryLevel) { success in
            self.hideLoader()
            
            if success {
                print("Friend successfully joined the circle!")
                self.navigateToHome()
            }
            else {
                self.showAlert(title: "Enter code Incorrect !!", message: "Failed to join the circle.")
            }
        }
    }
}


extension JoinCircleVC: AEOTPTextFieldDelegate {
 
    func didUserFinishEnter(the code: String) {
        friendEnterCode = code
        print(code)
    }
}
