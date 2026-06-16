//
//  PhoneAuthVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit
import SKCountryPicker
import PhoneNumberKit
class PhoneAuthVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var continueButton: PrimaryButton!
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    // MARK: - PROPERTY
    let phoneNumberUtility = PhoneNumberUtility()
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefault()
        setupContinueButton()
        setNativeAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupDefault(){
        lblCountryCode.text = CountryManager.shared.currentCountry?.dialingCode
        countryImage.image = CountryManager.shared.currentCountry?.flag
        
        txtPhoneNumber.addTarget(self, action: #selector(phoneNumberDidChange(_:)), for: .editingChanged)
        txtPhoneNumber.delegate = self
    }
    
    func setupLocalization() {
        self.txtPhoneNumber.placeholder = L10n.enterYourPhoneNumber
        self.lblTitle.text = L10n.enterYourPhoneNumber
        self.lblInfo.text = L10n.privacyInfo
        self.continueButton.setTitle(L10n.continue, for: .normal)
    }
    
    func setupContinueButton() {
        let length = (txtPhoneNumber.text ?? "").count
        continueButton.isEnabled = length >= 11
        fieldView.borderColor = length == 0 ? Asset.appLightGrey.color : Asset.appMain.color
    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func continueButtonClick(_ sender: PrimaryButton) {
        let phoneCode = CountryManager.shared.currentCountry?.dialingCode ?? ""
        let phoneNumber = (txtPhoneNumber.text ?? "").removingSpaces
        let fullNumber = "\(phoneCode)\(phoneNumber)".removingSpaces
        
        Loader.show("Loading...")
        FirebaseManager.shared.logAnalyticsEvent(name: .enter_click_continue)
        FirebaseManager.shared.sendMobileOTP(phoneNumber: fullNumber) { success, error in
            Loader.hide()
            showToast(message: error ?? "")
            if success {
                AdManager.shared.showInterstitialAd(from: self) {
                    let vc = StoryboardScene.AuthFlow.otpVerificationVC.instantiate()
                    vc.phoneCode = phoneCode
                    vc.phoneNumber = phoneNumber
                    vc.fullNumber = fullNumber
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func ClickaddNumber(_ sender: UITextField) {
        FirebaseManager.shared.logAnalyticsEvent(name: .enter_click_addnumber)
    }
    
    @IBAction func clickCountryCode(_ sender: UIButton) {
        self.presentCountryCodePicker { countryCode, flag in
            self.countryImage.image = flag
            self.lblCountryCode.text = countryCode
        }
    }
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    @objc func phoneNumberDidChange(_ textField: UITextField) {
        setupContinueButton()
    }
    
}
extension PhoneAuthVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Active TextField: \(textField.placeholder ?? "")")
        fieldView.borderColor = Asset.appMain.color
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setupContinueButton()
    }
}
