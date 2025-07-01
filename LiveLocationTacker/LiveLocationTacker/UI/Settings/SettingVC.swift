//
//  SettingVC.swift
//  InstaVideoSaver
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
    var settingDeatils:[AppCommonModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
}

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
            break
        case .RATE_NOW:
            openAppStoreForRating()
        case .SHARE:
            self.share(message: "", link: Constants.APP_URL)
        case .FEEDBACK:
            presentFeedbackMailComposer()
        case .PRIVACY_POLICY:
            openPrivacyPolicy()
        case .TERMS_CONDITION:
            openTermCondition()
        case .SUBSCRIPTION:
            restorePurchase()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withType: SettingHeaderView.self)
        headerView.lbl_name.text = Constants.USERDEFAULTS.getCurrentuserName()
        headerView.lbl_number.text = Constants.USERDEFAULTS.getCurrentuserNumber()
        headerView.profile_img.image = UIImage(data: Constants.USERDEFAULTS.getProfileImage() ?? Data())
        
        headerView.onTapProfileAction = {
            //self.pushVC(T: ProfileVC.instantiate(appStoryboard: .tabbar), viewControllerID: String(describing: ProfileVC.self ))
            let vc = StoryboardScene.Settings.profileVC.instantiate()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        headerView.onTapSubscribeAction = {
            DispatchQueue.main.async {
                let vc = StoryboardScene.Settings.subscribeVC.instantiate()
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 570
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // FEEDBACK
    func presentFeedbackMailComposer() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([Constants.FEEDBACK_MAILID]) // Replace with your email address
            mailComposer.setSubject("Feedback for Our \(Constants.APP_NAME)")
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
    
    // PRIVACY
    func openPrivacyPolicy() {
        // Replace with your actual privacy policy URL
        guard let privacyPolicyURL = URL(string: Constants.PRIVACY) else {
            print("Invalid URL")
            return
        }
        
        let safariVC = SFSafariViewController(url: privacyPolicyURL)
        safariVC.modalPresentationStyle = .fullScreen // Optional: Use full screen presentation style
        DispatchQueue.main.async {
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    
    // Terms
    func openTermCondition() {
        // Replace with your actual privacy policy URL
        guard let privacyPolicyURL = URL(string: Constants.TERMS) else {
            print("Invalid URL")
            return
        }
        
        let safariVC = SFSafariViewController(url: privacyPolicyURL)
        safariVC.modalPresentationStyle = .fullScreen // Optional: Use full screen presentation style
        DispatchQueue.main.async {
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    
    // RATING
    func openAppStoreForRating() {
        guard let appStoreURL = URL(string: Constants.RATE_URL) else {
            print("Invalid App Store URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(appStoreURL) {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
    }
    
    
    //Restore
    func restorePurchase(){
        showLoader(text: "loading")
        
        Purchases.shared.restorePurchases { (purchaserInfo, error) in
            self.hideLoader()
            self.refreshUserDetails()
        }
    }
    
    func refreshUserDetails() {
        Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements[Constants.entitlementID]?.isActive == true {
                //Constants.USERDEFAULTS.set(true, forKey: "pro")
                DefaultManager.IS_SUBSCRIPTION = true
                
                // Create the alert controller
                let alertController = UIAlertController(title: "restore_complete", message: "yoursubrestored", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "ok", style: .default) {
                    UIAlertAction in
                    self.navigateToHome()
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                self.showAlert(title: "nosubavailble", message: "plzsubcribefirst")
//                Constants.USERDEFAULTS.removeObject(forKey: "pro")
                DefaultManager.IS_SUBSCRIPTION = false
            }
        }
    }
}

extension SettingVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
