//
//  PopupEnableChildmode.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 11/08/25.
//

import UIKit

class PopupEnableChildmode: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lbllocation: UILabel!
    @IBOutlet weak var lblBettry: UILabel!
    @IBOutlet weak var lblLogout: UILabel!
    @IBOutlet weak var btnDisable: UIButton!
    @IBOutlet weak var lblLearChildMode: UILabel!
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setNativeAd()
    }
    
    // MARK: - UI SETUP
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    func setupLocalization() {
        self.lblTitle.text = L10n.ChildModeIsEnabled
        self.lblSubTitle.text = L10n.youCantTurnOffLocationAndBatteryLevelSharingOrLogout
        self.lbllocation.text = L10n.locationSharing
        self.lblBettry.text = L10n.batteryLevelSharing
        self.lblLogout.text = L10n.logOut
        self.lblLearChildMode.text = L10n.LearnMoreAboutChildMode
        self.btnDisable.setTitle(L10n.disable, for: .normal)
    }
    
    // MARK: - Setup Ads
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func closeButtonClick(_ sender: UIButton) {
        self.navigateBack()
    }
    
    @IBAction func clickLearnMode(_ sender: UIButton) {
        AdManager.shared.showInterstitialAd(from: self) {
            let vc = StoryboardScene.Child.aboutChildModeVC.instantiate()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func disableClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .setting_childmode_click_diable)
        let vc = StoryboardScene.Child.popupRequestToDisable.instantiate()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
