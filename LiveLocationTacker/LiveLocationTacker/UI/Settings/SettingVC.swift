//
//  SettingVC.swift
//
//  Created by DREAMWORLD on 11/10/24.
//

import UIKit
import MessageUI
import SafariServices
import RevenueCat
class SettingVC: UIViewController {
    
    @IBOutlet weak var main_view: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIView!
    
    var settingDeatils:[AppCommonModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseManager.shared.logAnalyticsEvent(name: .home_click_setting)
        settingDeatils = [
            AppCommonModel(id: .CHILD_MODE, image: UIImage(named: "icon_permission_childmode"), title: "Child Mode"),
            //AppCommonModel(id: .DARK_MODE, image: UIImage(named: "icon_dark_mode"), title: "Dark Mode"),
            AppCommonModel(id: .RATE_NOW, image: UIImage(named: "icon_rate_us"), title: "Rate now"),
            AppCommonModel(id: .SHARE, image: UIImage(named: "icon_share_app"), title: "Share app"),
            AppCommonModel(id: .FEEDBACK, image: UIImage(named: "icon_feedback_app"), title: "Feedback"),
            AppCommonModel(id: .PRIVACY_POLICY, image: UIImage(named: "icon_privacy_policy"), title: "Privacy policy"),
            AppCommonModel(id: .TERMS_CONDITION, image: UIImage(named: "icon_term_condition"), title: "Term & condition"),
            AppCommonModel(id: .SUBSCRIPTION, image: UIImage(named: "icon_subscription"), title: "Restor Purchase")
        ]
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 75
        self.tableView.registerHeaderFooterView(of: SettingHeaderView.self)
        self.tableView.register(UINib(nibName: "SettingTVCell", bundle: nil), forCellReuseIdentifier: "SettingTVCell")
        self.setBannerAds()
    }
    
    // MARK: - Setup Ads
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SettingVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingDeatils.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTVCell", for: indexPath) as! SettingTVCell
        let options = settingDeatils[indexPath.row]
        cell.img_view.image = options.image
        cell.lbl_title.text = options.title
        
        cell.lblChildModeLabel.isHidden = options.id != .CHILD_MODE
        cell.btnSwitch.isHidden = options.id != .DARK_MODE
        cell.img_arrow.isHidden = options.id == .DARK_MODE
        cell.btnActive.isHidden = !(options.id == .SUBSCRIPTION && DefaultManager.IS_SUBSCRIPTION)
        cell.btnInActive.isHidden = !(options.id == .SUBSCRIPTION && !DefaultManager.IS_SUBSCRIPTION)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let options = settingDeatils[indexPath.row]
        switch options.id {
        case.CHILD_MODE:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_childmode : .setting_click_childmode)
            if DefaultManager.User.IS_CHILD_MODE_ENABLE {
                let vc = StoryboardScene.ChildMode.popupEnableChildmode.instantiate()
                self.present(vc, animated: true)
            } else {
                let vc = StoryboardScene.ChildMode.popupInviteChildMode.instantiate()
                self.present(vc, animated: true)
            }
            break
        case .RATE_NOW:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_rateus : .setting_click_ratenow)
            openAppStoreForRating()
        case .SHARE:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_share : .setting_click_share)
            self.share(message: "", link: APP_URL)
        case .FEEDBACK:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_feedback : .setting_click_feedback)
            presentFeedbackMailComposer()
        case .PRIVACY_POLICY:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_privacy : .setting_click_privecy_policy)
            openPrivacyPolicy()
        case .TERMS_CONDITION:
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_terms : .setting_click_terms)
            openTermCondition()
        case .SUBSCRIPTION:
            FirebaseManager.shared.logAnalyticsEvent(name: .setting_click_subscription)
            if DefaultManager.IS_SUBSCRIPTION {
                let vc = StoryboardScene.Settings.activeSubscriptionListVC.instantiate()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                restorePurchase()
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withType: SettingHeaderView.self)
        headerView.lbl_name.text = DefaultManager.User.NAME
        headerView.lbl_number.text = DefaultManager.User.PHONE
        //headerView.profile_img.image = UIImage(data: DefaultManager.User.PROFILE_DATA ?? Data())
        headerView.profile_img.setImage(urlString: DefaultManager.User.PROFILE_PIC, name: DefaultManager.User.NAME, placeholderImage: Asset.iconDefaultProfile.image, width: headerView.profile_img.frame.width * 2, height: headerView.profile_img.frame.height * 2)
        
        headerView.premiumView.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE
        headerView.permissionView.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE
        
        headerView.onTapProfileAction = {
            FirebaseManager.shared.logAnalyticsEvent(name: DefaultManager.User.IS_CHILD_MODE_ENABLE ? .childmode_setting_click_profile : .setting_click_profile)
            AdManager.shared.showInterstitialAd(from: self) {
                let vc = StoryboardScene.Settings.profileVC.instantiate()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        headerView.onTapSubscribeAction = {
            FirebaseManager.shared.logAnalyticsEvent(name: .setting_click_premium)
//            if DefaultManager.IS_SUBSCRIPTION {
                DispatchQueue.main.async {
                    let vc = StoryboardScene.Settings.activeSubscriptionListVC.instantiate()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
//            } else {
//                DispatchQueue.main.async {
//                    let vc = StoryboardScene.Settings.choosePlanVC.instantiate()
//                    vc.modalPresentationStyle = .overFullScreen
//                    self.present(vc, animated: true)
//                }
//            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DefaultManager.User.IS_CHILD_MODE_ENABLE ? 105 : 570
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Feedback
    func presentFeedbackMailComposer() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([FEEDBACK_MAILID]) // Replace with your email address
            mailComposer.setSubject("Feedback for Our \(APP_NAME)")
            mailComposer.setMessageBody("Please provide your feedback here...", isHTML: false)
            
            DispatchQueue.main.async {
                self.present(mailComposer, animated: true, completion: nil)
            }
        }
        else {
            // Handle the case where the device cannot send email
            print("Mail services are not available.")
        }
    }
    
    // MARK: - Privacy Policy
    func openPrivacyPolicy() {
        // Replace with your actual privacy policy URL
        guard let privacyPolicyURL = URL(string: PRIVACY) else {
            print("Invalid URL")
            return
        }
        
        let safariVC = SFSafariViewController(url: privacyPolicyURL)
        safariVC.modalPresentationStyle = .fullScreen // Optional: Use full screen presentation style
        DispatchQueue.main.async {
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Terms & Conditions
    func openTermCondition() {
        // Replace with your actual privacy policy URL
        guard let privacyPolicyURL = URL(string: TERMS) else {
            print("Invalid URL")
            return
        }
        
        let safariVC = SFSafariViewController(url: privacyPolicyURL)
        safariVC.modalPresentationStyle = .fullScreen // Optional: Use full screen presentation style
        DispatchQueue.main.async {
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - App Rating
    func openAppStoreForRating() {
        guard let appStoreURL = URL(string: RATE_URL) else {
            print("Invalid App Store URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(appStoreURL) {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Subscription Restore
    func restorePurchase(){
        showLoader(text: "loading")
        RevenueCatManager.shared.restorePurchases { isActive in
            hideLoader()
            if isActive {
                DefaultManager.IS_SUBSCRIPTION = true
                
                let alertController = UIAlertController(title: "Restore Complete", message: "Your subscription has been restored.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "ok", style: .default) { _ in
                    self.navigateToHome()
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.showAlert(title: "No Subscription Available", message: "Please subscribe first.")
                DefaultManager.IS_SUBSCRIPTION = false
            }
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
