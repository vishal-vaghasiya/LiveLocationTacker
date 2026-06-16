//
//  SettingsVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 06/08/25.
//

import UIKit

class SettingsVC: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var batterySwitch: UISwitch!
    @IBOutlet weak var proximitySwitch: UISwitch!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblChildModeTitle: UILabel!
    @IBOutlet weak var lblChildModeSubTitle: UILabel!
    @IBOutlet weak var lblChangeLanguageTitle: UILabel!
    @IBOutlet weak var lblBatteryLevelTitle: UILabel!
    @IBOutlet weak var lblProximityTitle: UILabel!
    @IBOutlet weak var lblMotionTitle: UILabel!
    @IBOutlet weak var lblLocationSharingTitle: UILabel!
    @IBOutlet weak var lblRateTitle: UILabel!
    @IBOutlet weak var lblShareTitle: UILabel!
    @IBOutlet weak var lblFeedbackTitle: UILabel!
    @IBOutlet weak var lblPrivacyTitle: UILabel!
    @IBOutlet weak var lblTermTitle: UILabel!
    
    @IBOutlet weak var permissionView: UIView!
    
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var btnLogout: UIButton!
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        //setBannerAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseManager.shared.isUserInAnyChildCircle()
        setupUI()
        setupPermission()
        setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        FirebaseManager.shared.logAnalyticsEvent(name: .home_click_setting)
        
        ivProfile.setImage(urlString: DefaultManager.User.PROFILE_PIC, name: DefaultManager.User.NAME, placeholderImage: Asset.iconSelectProfile.image)
        lblName.text = DefaultManager.User.NAME.isEmpty ? "-" : DefaultManager.User.NAME
        lblMobile.text = DefaultManager.User.PHONE.isEmpty ? "-" : DefaultManager.User.PHONE
        logoutView.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE
        permissionView.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE
    }
    
    func setBannerAds() {
        AdManager.shared.loadBannerAd(in: self.bannerView, rootViewController: self) { isShow in
            if isShow {
                UIView.animate(withDuration: 0.5) {
                    self.contBannerHeight.constant = 50
                    self.view.layoutIfNeeded()
                }
            } else {
                self.contBannerHeight.constant = 0
            }
        }
    }
    
    func setupPermission(){
        batterySwitch.isOn = DefaultManager.Permission.BATTERY
        proximitySwitch.isOn = DefaultManager.Permission.PROXIMITY_NOTIFICATION
    }
    
    func setupLocalization() {
        lblChildModeTitle.text = L10n.childMode
        lblChildModeSubTitle.text = L10n.childModeSubTitle
        lblTitle.text = L10n.settings
        lblChangeLanguageTitle.text = L10n.changeLanguage
        lblBatteryLevelTitle.text = L10n.batteryLevelSharing
        lblProximityTitle.text = L10n.proximityNotifications
        lblMotionTitle.text = L10n.motionActivity
        lblLocationSharingTitle.text = L10n.locationSharing
        lblRateTitle.text = L10n.rateNow
        lblShareTitle.text = L10n.share
        lblFeedbackTitle.text = L10n.feedback
        lblPrivacyTitle.text = L10n.privacyPolicy
        lblTermTitle.text = L10n.termCondition
        btnLogout.setTitle(L10n.logOut, for: .normal)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func editButtonClick(_ sender: Any) {
        FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_profile : .setting_click_profile)
        AdManager.shared.showInterstitialAd(from: self) {
            let vc = StoryboardScene.Profile.editProfileVC.instantiate()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func permissionSwitch(_ sender: UISwitch) {
        let type = SettingPermissionType(rawValue: sender.tag)
        switch type {
        case .batteryLevel:
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .setting_batterylevalsharing_enable : .setting_betterylevalsharing_diable)
            DefaultManager.Permission.BATTERY = sender.isOn
            break
        case .proximityNotifications:
            DefaultManager.Permission.PROXIMITY_NOTIFICATION = sender.isOn
            break
        default:
            break
        }
    }
    
    @IBAction func clickMotion(_ sender: UIButton) {
        AdManager.shared.showInterstitialAd(from: self) {
            let vc = StoryboardScene.Permission.setupPermissionVC.instantiate()
            vc.permissionType = .Motion_Activity
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clickLocation(_ sender: UIButton) {
        AdManager.shared.showInterstitialAd(from: self) {
            let vc = StoryboardScene.Permission.setupPermissionVC.instantiate()
            vc.permissionType = .Location_Sharing
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func optionButtonClick(_ sender: UIButton) {
        let type = SettingOptionType(rawValue: sender.tag)
        switch type {
        case .childMode:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_childmode : .setting_click_childmode)
            if DefaultManager.User.IS_CHILD_MODE_ENABLE {
                AdManager.shared.showInterstitialAd(from: self) {
                    let vc = StoryboardScene.Child.popupEnableChildmode.instantiate()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                fetchOwnedChildCircles { circles in
                    if circles.count == 0 { return }
                    if circles.count > 1 {
                        let vc = StoryboardScene.Child.childModeCircleListVC.instantiate()
                        vc.arrOfCricle = circles
                        vc.circleSelectEvent = { selectedCircle in
                            AdManager.shared.showInterstitialAd(from: self) {
                                let vc = StoryboardScene.Child.childModeVC.instantiate()
                                vc.circleInfo = selectedCircle
                                vc.hidesBottomBarWhenPushed = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                        vc.hidesBottomBarWhenPushed = true
                        vc.modalPresentationStyle = .overCurrentContext
                        self.present(vc, animated: false)
                    } else {
                        AdManager.shared.showInterstitialAd(from: self) {
                            let vc = StoryboardScene.Child.childModeVC.instantiate()
                            vc.circleInfo = circles[0]
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
            break
        case .rateNow:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_rateus : .setting_click_ratenow)
            openAppStorePageForRating()
            break
        case .language:
            AdManager.shared.showInterstitialAd(from: self) {
                let vc = StoryboardScene.Main.selectLanguageVC.instantiate()
                vc.changeLungEvent = {
                    if let tabbar = self.tabBarController as? MainTabBarController {
                        tabbar.setupTabNames()
                    }
                }
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case .share:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_share : .setting_click_share)
            shareContent(link: AppURL)
            break
        case .feedback:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_feedback : .setting_click_feedback)
            MailComposerHelper.shared.presentFeedbackEmail(from: self)
            break
        case .privacyPolicy:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_privacy : .setting_click_privecy_policy)
            presentPrivacyPolicy(from: self)
            break
        case .termsAndCondition:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_terms : .setting_click_terms)
            presentTermsAndConditions(from: self)
            break
        default :
            break
        }
    }
    
    @IBAction func logoutButtonClick(_ sender: UIButton) {
        Loader.show("Updating...")
        let updatedData: [String: Any] = [
            FirebaseKeys.fcmtoken: ""
        ]
        FirebaseManager.shared.updateUserData(updatedValues: updatedData) { success, message in
            Loader.hide()
            DefaultManager.removeAll()
            goToWelcome()
        }
    }
    
    // MARK: - OTHER
    func fetchOwnedChildCircles(completion: @escaping ([CircleInfo]) -> Void) {
        Loader.show("Loading...")
        FirebaseManager.shared.fetchCirclesOwnedByCurrentUser { success, message, circles in
            if success {
                Loader.hide()
                completion(circles)
            } else {
                showToast(message: message)
            }
        }
    }
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
