//
//  MobileOTPVerificationVC.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 25/06/25.
//

import UIKit
import FirebaseAuth
class MobileOTPVerificationVC: UIViewController , UIGestureRecognizerDelegate {
    // MARK: - OUTLET
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet var lblMobileNumber: UILabel!
    
    @IBOutlet weak var txtOTP: UITextField!
    
    @IBOutlet weak var resentStackView: UIStackView!
    @IBOutlet weak var lblResendOTP: UILabel!
   
    @IBOutlet var viewOTP: [UIView]!
    
    
    @IBOutlet weak var btnVerify: UIEnableDisable!
    // MARK: - PROPERTY
    var count = 30  // 60sec if you want
    var resendTimer = Timer()
    
    var data = NSDictionary()
    var mobileNumber = String()
    var name = String()
    var displayMobileNumber = String()
    var selectedContryID = Int()
    var phoneCode = String()
    let firebaseManager = FirebaseManager()
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        setupData()
    }
    
    func startTimer(){
        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    // MARK: - UI SETUP
    func setupData(){
        lblMobileNumber.text = "Enter the OTP Sent to \(phoneCode) \(displayMobileNumber)"
        self.txtOTP.keyboardType = .numberPad
        self.txtOTP.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        startTimer()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    @objc func update() {
        if(count > 0) {
            count = count - 1
            lblResendOTP.text = "Resend OTP in 00:\(String(format: "%02d", count))"
            resentStackView.isHidden = true
            lblResendOTP.isHidden = false
        } else {
            count = 30
            lblResendOTP.text = "Resend OTP in 00:00"
            resendTimer.invalidate()
            resentStackView.isHidden = false
            lblResendOTP.isHidden = true
        }
    }
    
    func resetTxtOtp() {
        self.txtOTP.text = ""
        
        let labels = [label1, label2, label3, label4, label5, label6]
        labels.forEach { $0?.text = "" }
    }

    // MARK: - BUTTON CLICK
    @IBAction func cancelClick(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func resendOTPClick(_ sender: UIButton) {
        self.resetTxtOtp()
        self.showLoader(text: "Loading...")
        
        firebaseManager.resendOTP(phoneNumber: mobileNumber) { success, error in
            self.hideLoader()
            self.showToastMessage(error ?? "")
            if success {
                self.count = 30
                self.startTimer()
            }
        }
    }
    
    @IBAction func verifyClick(_ sender: UIEnableDisable) {
        self.showLoader(text: "Loading...")
        self.firebaseManager.verifyOTP(otpCode: txtOTP.text ?? "") { success, error in
            self.hideLoader()
            self.showToastMessage(error ?? "")
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    self.creatingStaticCircle()
                })
            }
        }
    }
    
    // MARK: - OTHER

    // MARK: - DELEGATE
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let strLength = text.count
        
        // Array of labels
        let labels = [label1, label2, label3, label4, label5, label6]
        
        // Update labels dynamically
        for (index, label) in labels.enumerated() {
            if index < strLength {
                label?.text = text.getCharacter(at: index)
            } else {
                label?.text = ""
            }
        }
        
        // Validate input length
        self.btnVerify.isEnabled = strLength >= 6
        if strLength == 6 {
            view.endEditing(true)
        } else if strLength > 6 {
            // Restrict input to 6 characters
            textField.text = String(text.prefix(6))
        }
    }
    
    func creatingStaticCircle(){
        showLoader(text: "Loading...")
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        
        //groupManager.deleteUserAccount(userPhoneNumber: txtEnterNumber.text ?? "") { [self] isDeleted in
        firebaseManager.createCircle(name: "My Circles",
                                     userName: name,
                                     userPhone: mobileNumber,
                                     batteryLevel: batteryLevel) { [self] generatedCode in
            print("Share this code with your friend: \(generatedCode ?? "")")
            
            Constants.USERDEFAULTS.saveCurrentuserNumber(value: name)
            Constants.USERDEFAULTS.saveCurrentuserName(value: mobileNumber)
            Constants.USERDEFAULTS.saveCurrentuserCode(value: generatedCode ?? "")
            Constants.USERDEFAULTS.saveBatterySharing(value: true)
            Constants.USERDEFAULTS.saveLocationSharing(value: true)
            Constants.USERDEFAULTS.saveNotificationSharing(value: true)
            Constants.USERDEFAULTS.saveProfileImage(value: UIImage(named: "engineer")?.pngData() ?? Data())
            
            self.hideLoader()
            
            self.pushVC(T: SetProfileVC.instantiate(appStoryboard: .main), viewControllerID: String(describing: SetProfileVC.self))
        }
        //}
    }
    
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

