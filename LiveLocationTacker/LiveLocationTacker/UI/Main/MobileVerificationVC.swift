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
    private var mobileNumber = String()
    var name = String()
    var phoneCode = String()
    var phoneNumber = String()
    var selectedContryID = Int()
    let firebaseManager = FirebaseManager.shared
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
        mobileNumber = "+\(phoneCode) \(phoneNumber)".removingSpaces
        lblMobileNumber.text = "Enter the OTP Sent to +\(phoneCode) \(phoneNumber)"
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
        
        firebaseManager.isExistingUser(phoneNumber.digitsOnly) { isExisting, data in
            if isExisting {
                self.hideLoader()
                let existingNumber = data?["admin"] as? String ?? ""
                let existingName = data?["name"] as? String ?? ""
                let existingCode = data?["code"] as? String ?? ""
                let existingCountryCode = "91"
                
                DefaultManager.User.COUNTRY_CODE = existingCountryCode//Need to update
                DefaultManager.User.PHONE = existingNumber
                DefaultManager.User.NAME = existingName
                DefaultManager.User.PROFILE_DATA = UIImage(named: "engineer")?.pngData() ?? Data()
                
                DefaultManager.Permission.LOCATION = true
                DefaultManager.Permission.BATTERY = true
                DefaultManager.Permission.NOTIFICATION = true
                DefaultManager.Permission.CAMERA = true
                DefaultManager.Permission.MOTION = true
                
                DefaultManager.Cirlce.CURRENT_CODE = existingCode
                
                let vc = StoryboardScene.Main.setProfileVC.instantiate()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                self.firebaseManager.createCircle(name: "My Circles",
                                                  userName: self.name,
                                                  countryCode: self.phoneCode,
                                                  userPhone: self.phoneNumber.digitsOnly,
                                                  batteryLevel: batteryLevel) { [self] generatedCode in
                    self.hideLoader()

                    DefaultManager.User.COUNTRY_CODE = phoneCode
                    DefaultManager.User.PHONE = mobileNumber.digitsOnly
                    DefaultManager.User.NAME = name
                    DefaultManager.User.PROFILE_DATA = UIImage(named: "engineer")?.pngData() ?? Data()
                    
                    DefaultManager.Permission.LOCATION = true
                    DefaultManager.Permission.BATTERY = true
                    DefaultManager.Permission.NOTIFICATION = true
                    DefaultManager.Permission.CAMERA = true
                    DefaultManager.Permission.MOTION = true
                    
                    DefaultManager.Cirlce.CURRENT_CODE = generatedCode ?? ""
                    
                    let vc = StoryboardScene.Main.setProfileVC.instantiate()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        /*LocationManager.shared.getCurrentLocation { location in
            LocationManager.shared.getGoogleAddress(lat: location.coordinate.latitude, long: location.coordinate.longitude) { address in
                
                let param: [String: Any] = [
                    FirebaseKeys.name: self.name,
                    FirebaseKeys.gender: "",
                    FirebaseKeys.countryCode: self.phoneCode,
                    FirebaseKeys.phone: self.phoneNumber.digitsOnly,
                    FirebaseKeys.profilePicture: "",
                    FirebaseKeys.batteryLevel: batteryLevel,
                    FirebaseKeys.fcmtoken: DefaultManager.User.FCM_TOKEN,
                    FirebaseKeys.latitude: location.coordinate.latitude,
                    FirebaseKeys.longitude: location.coordinate.longitude,
                    FirebaseKeys.address: address ?? "N/A",
                    FirebaseKeys.timestamp: Date().getCurrentUTCTimestampInfo().timestampSeconds
                ]
                
                self.firebaseManager.checkAndSaveUser(phoneNumber: self.phoneNumber.digitsOnly, param: param) { success, message, userData  in
                    self.hideLoader()
                    print(message)
                    if success {
                        if let user = userData {
                            print("User Data: \(user)")
                            
                            let name = user[FirebaseKeys.name] as? String ?? ""
                            let gender = user[FirebaseKeys.gender] as? String ?? ""
                            let countryCode = user[FirebaseKeys.countryCode] as? String ?? ""
                            let phone = user[FirebaseKeys.phone] as? String ?? ""
                            let profile = user[FirebaseKeys.profilePicture] as? String ?? ""
                            
                            DefaultManager.User.NAME = name
                            DefaultManager.User.GENDER = gender
                            DefaultManager.User.COUNTRY_CODE = countryCode
                            DefaultManager.User.PHONE = phone
                            DefaultManager.User.PROFILE_PIC = profile
                            
                            DefaultManager.Permission.LOCATION = true
                            DefaultManager.Permission.BATTERY = true
                            DefaultManager.Permission.NOTIFICATION = true
                            DefaultManager.Permission.CAMERA = true
                            DefaultManager.Permission.MOTION = true
                            
                            let vc = StoryboardScene.Main.setProfileVC.instantiate()
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        self.showToastMessage(message)
                    }
                }
                
            }
        }*/
        
    }
}
