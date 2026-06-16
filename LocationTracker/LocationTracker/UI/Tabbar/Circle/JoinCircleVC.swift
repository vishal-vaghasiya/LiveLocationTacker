//
//  JoinCircleVC.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 03/09/25.
//

import UIKit
import AEOTPTextField

class JoinCircleVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnJoin: PrimaryButton!
    @IBOutlet weak var lblEnterCode: UILabel!
    @IBOutlet weak var txtOTP: AEOTPTextField!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var warningView: UIStackView!
    @IBOutlet weak var lblWarning: UILabel!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.warningView.isHidden = true
        self.setupOTPTextField()
        self.setupContinueButton()
        self.setNativeAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    
    func setupLocalization() {
        self.lblTitle.text = L10n.joinCircle
        self.btnJoin.setTitle(L10n.join, for: .normal)
        self.lblEnterCode.text = L10n.enterInvitationCode
        self.lblDescription.attributedText = L10n.getAnInvitationCodeFromThePersonWhoMadeTheCircl.lineSpacing(noOfLine: 3)
        self.lblWarning.text = L10n.pleaseEnterValidCode
    }
    
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

        txtOTP.keyboardType = .default
        txtOTP.clearOTP()
    }
    
    func setupContinueButton() {
        let length = (txtOTP.text ?? "").count
        btnJoin.isEnabled = length == 6
    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickBac(_ sender: UIButton) {
        self.navigateBack()
    }
    
    @IBAction func clickJoin(_ sender: PrimaryButton) {
        Loader.show("Joing...")
        FirebaseManager.shared.logAnalyticsEvent(name: .addmember_click_joincircle)
        FirebaseManager.shared.joinCircle(inviteCode: self.txtOTP.text ?? "") { success, message in
            Loader.hide()
            if success {
                goToDashboard()
            } else {
                self.warningView.isHidden = false
                //showToast(message: message)
            }
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}

extension JoinCircleVC: AEOTPTextFieldDelegate {
    func didUserFinishEnter(the code: String) {
        setupContinueButton()
        txtOTP.resignFirstResponder()
    }
    
    @objc func didChange(_ textField: UITextField) {
        setupContinueButton()
    }
}
