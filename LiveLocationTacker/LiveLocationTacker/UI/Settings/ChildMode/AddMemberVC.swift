//
//  AddMemberVC.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 02/07/25.
//

import UIKit
import AEOTPTextField

class AddMemberVC: UIViewController {
    // MARK: - OUTLET
    @IBOutlet weak var btnSendCode: UIEnableDisable!
    @IBOutlet weak var otpTextField: AEOTPTextField!

    // MARK: - PROPERTY
    var groupCode = String()
    var closeHandler: (() -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSendCode.isEnabled = true
        
        otpTextField.otpDelegate = self
        otpTextField.otpCornerRaduis = 5
        otpTextField.otpBackgroundColor = .white.withAlphaComponent(0.15)
        otpTextField.otpFilledBorderWidth = 0
        otpTextField.otpFilledBorderColor = .clear
        otpTextField.otpFont = AppFont.semiBold(size: 28) ?? UIFont()
        otpTextField.otpTextColor = .btncolor
        otpTextField.otpFilledBackgroundColor = .white.withAlphaComponent(0.15)
        otpTextField.configure(with: 6)
        otpTextField.isUserInteractionEnabled = false
        
        // ✅ Programmatically insert OTP
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.otpTextField.insertText("ABCDEF")
        }
    }
    
    // MARK: - UI SETUP
    
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backClick(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.closeHandler?()
        }
    }
    
    @IBAction func sendCodeClick(_ sender: UIButton) {
        share(message: otpTextField.text ?? "", link: "")
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
extension AddMemberVC: AEOTPTextFieldDelegate {
    func didUserFinishEnter(the code: String) {
        
    }
}
