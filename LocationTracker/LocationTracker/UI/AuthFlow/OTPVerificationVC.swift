//
//  OTPVerificationVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit
import AEOTPTextField

class OTPVerificationVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblOTPVerify: UILabel!
    @IBOutlet weak var txtOTP: AEOTPTextField!
    @IBOutlet weak var continueButton: PrimaryButton!
    @IBOutlet weak var lblSendOTPNumber: UILabel!
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    @IBOutlet weak var lblNotRecive: UILabel!
    @IBOutlet weak var btnResent: UIButton!
    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var ivIcon: UIImageView!
    
    // MARK: - PROPERTY
    var phoneCode = String()
    var phoneNumber = String()
    var fullNumber = String()
    var message = (error: "Please enter valid OTP code", success: "Verified")

    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageStackView.isHidden = true
        setupOTPTextField()
        setupContinueButton()
        setNativeAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupOTPTextField() {
        txtOTP.otpDelegate = self
        txtOTP.otpDefaultCharacter = ""
        txtOTP.otpCornerRaduis = 5
        txtOTP.otpBackgroundColor = .clear
        txtOTP.otpTextColor = Asset.appBlack.color
        txtOTP.otpFont = FontFamily.Poppins.medium.font(size: 20)

        // First configure slots
        txtOTP.configure(with: 6)

        // Now apply border styles so they show immediately
        txtOTP.otpDefaultBorderWidth = 1
        txtOTP.otpDefaultBorderColor = Asset.appLightGrey.color
        txtOTP.otpFilledBorderWidth = 1
        txtOTP.otpFilledBorderColor = Asset.appMain.color
        txtOTP.otpFilledBackgroundColor = .clear

        // Focus immediately
        txtOTP.becomeFirstResponder()

        txtOTP.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)

        lblSendOTPNumber.text = "Enter the OTP Sent to \(fullNumber.formattedPhoneNumber())"
        txtOTP.clearOTP()
    }
    
    func setupLocalization() {
        self.lblOTPVerify.text = L10n.otpVerification
        self.lblSendOTPNumber.text = L10n.enterTheOTPSentTo + " \(fullNumber.formattedPhoneNumber())"
        self.lblNotRecive.text = L10n.donTReceiveTheOTP
        self.btnResent.setTitle(L10n.resendOtp, for: .normal)
        self.continueButton.setTitle(L10n.continue, for: .normal)
    }
    
    func setupContinueButton() {
        let length = (txtOTP.text ?? "").count
        continueButton.isEnabled = length == 6
    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func continueButtonClick(_ sender: UIButton) {
        txtOTP.resignFirstResponder()
        Loader.show("Loading...")
        FirebaseManager.shared.logAnalyticsEvent(name: .otp_click_verify)
        FirebaseManager.shared.verifyOTP(otpCode: self.txtOTP.text ?? "") { success, error in
            Loader.hide()
            self.messageStackView.isHidden = false
            if success {
                self.lblMessage.text = self.message.success
                self.lblMessage.textColor = Asset.appGreen.color
                self.ivIcon.image = Asset.iconSuccessTick.image
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    self.creatingStaticCircle()
                })
            } else {
                self.lblMessage.text = error
                self.lblMessage.textColor = Asset.appRed.color
                self.ivIcon.image = Asset.iconErrorInfo.image
            }
        }
    }
    
    @IBAction func resendOTPClick(_ sender: UIButton) {
        Loader.show("Loading...")
        FirebaseManager.shared.logAnalyticsEvent(name: .otp_click_resend)
        FirebaseManager.shared.resendOTP(phoneNumber: fullNumber) { success, error in
            Loader.hide()
            showToast(message: error ?? "")
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    func creatingStaticCircle(){
        Loader.show("Loading...")
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = Int(UIDevice.current.batteryLevel * 100)
        
        LocationManager.shared.fetchCurrentLocation { location in
            LocationManager.shared.getAddressFrom(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { address in
                
                let param: [String: Any] = [
                    FirebaseKeys.name: "",
                    FirebaseKeys.gender: "",
                    FirebaseKeys.countryCode: self.phoneCode,
                    FirebaseKeys.phone: self.phoneNumber,
                    FirebaseKeys.profilePicture: "",
                    FirebaseKeys.batteryLevel: level,
                    FirebaseKeys.fcmtoken: DefaultManager.User.FCM_TOKEN,
                    FirebaseKeys.latitude: location.coordinate.latitude,
                    FirebaseKeys.longitude: location.coordinate.longitude,
                    FirebaseKeys.address: address ?? "N/A",
                    FirebaseKeys.timestamp: Date().getCurrentUTCTimestampInfo().timestampSeconds,
                    
                    FirebaseKeys.childMode: [
                        FirebaseKeys.code : "",
                        FirebaseKeys.enabled : 0,
                        FirebaseKeys.ownerPhone : "",
                    ]
                ]
                
                FirebaseManager.shared.checkAndSaveUser(phoneNumber: self.phoneNumber, param: param) { success, message, userData  in
                    Loader.hide()
                    if success {
                        if let user = userData {
                            let firstName = user[FirebaseKeys.fName] as? String ?? ""
                            let lastName = user[FirebaseKeys.lName] as? String ?? ""
                            let gender = user[FirebaseKeys.gender] as? String ?? ""
                            let countryCode = user[FirebaseKeys.countryCode] as? String ?? ""
                            let phone = user[FirebaseKeys.phone] as? String ?? ""
                            let profile = user[FirebaseKeys.profilePicture] as? String ?? ""
                            
                            DefaultManager.User.FIRST_NAME = firstName
                            DefaultManager.User.LAST_NAME = lastName
                            DefaultManager.User.GENDER = gender
                            DefaultManager.User.COUNTRY_CODE = countryCode
                            DefaultManager.User.PHONE = phone
                            DefaultManager.User.PROFILE_PIC = profile
                            
                            DefaultManager.Permission.LOCATION = true
                            DefaultManager.Permission.BATTERY = true
                            DefaultManager.Permission.NOTIFICATION = true
                            DefaultManager.Permission.CAMERA = true
                            DefaultManager.Permission.MOTION = true
                            
                            AdManager.shared.showInterstitialAd(from: self) {
                                let vc = StoryboardScene.Profile.setupProfileVC.instantiate()
                                vc.hidesBottomBarWhenPushed = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    } else {
                        showToast(message: message)
                    }
                }
            }
        }
    }
    // MARK: - DELEGATE

}
extension OTPVerificationVC: AEOTPTextFieldDelegate {
    func didUserFinishEnter(the code: String) {
        setupContinueButton()
        txtOTP.resignFirstResponder()
    }
    
    @objc func didChange(_ textField: UITextField) {
        setupContinueButton()
    }
}
