//
//  AboutChildModeVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 09/09/25.
//

import UIKit

class AboutChildModeVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblAboutChildMode: UILabel!
    @IBOutlet weak var lblChildModeOnExplanation: UILabel!
    @IBOutlet weak var lblChildModeLocationAlwaysActive: UILabel!
    @IBOutlet weak var lblChildModeBatteryVisible: UILabel!
    @IBOutlet weak var lblChildModeLogoutDisabled: UILabel!
    @IBOutlet weak var lblChildModeSafetyDesigned: UILabel!
    @IBOutlet weak var lblHowToTurnOffChildMode: UILabel!
    @IBOutlet weak var lblCircleOwnerCanDisableChildMode: UILabel!
    @IBOutlet weak var lblMemberDisableRequestApproval: UILabel!
    @IBOutlet weak var lblChildModeDisabledAfterApproval: UILabel!
    @IBOutlet weak var lblWhyUseChildMode: UILabel!
    @IBOutlet weak var lblChildModeEnsuresSafety: UILabel!
    @IBOutlet weak var lblChildModePreventsLocationHiding: UILabel!
    @IBOutlet weak var lblChildModeParentalControl: UILabel!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setNativeAd()
        setupLocalization()
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backClick(_ sender: UIButton) {
        self.navigateBack()
    }
    
    // MARK: - OTHER
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    func setupLocalization() {
        lblAboutChildMode.text = L10n.aboutChildMode
        lblChildModeOnExplanation.text = L10n.childModeOnExplanation
        lblChildModeLocationAlwaysActive.text = L10n.childModeLocationAlwaysActive
        lblChildModeBatteryVisible.text = L10n.childModeBatteryVisible
        lblChildModeLogoutDisabled.text = L10n.childModeLogoutDisabled
        lblChildModeSafetyDesigned.text = L10n.childModeSafetyDesigned
        lblHowToTurnOffChildMode.text = L10n.howToTurnOffChildMode
        lblCircleOwnerCanDisableChildMode.text = L10n.circleOwnerCanDisableChildMode
        lblMemberDisableRequestApproval.text = L10n.memberDisableRequestApproval
        lblChildModeDisabledAfterApproval.text = L10n.childModeDisabledAfterApproval
        lblWhyUseChildMode.text = L10n.whyUseChildMode
        lblChildModeEnsuresSafety.text = L10n.childModeEnsuresSafety
        lblChildModePreventsLocationHiding.text = L10n.childModePreventsLocationHiding
        lblChildModeParentalControl.text = L10n.childModeParentalControl
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
