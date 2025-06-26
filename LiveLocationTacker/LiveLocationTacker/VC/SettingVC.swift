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
            AppCommonModel(image: UIImage(named: "ic_setting_1"), title: "Rate now"),
            AppCommonModel(image: UIImage(named: "ic_setting_2"), title: "Share app"),
            AppCommonModel(image: UIImage(named: "ic_setting_3"), title: "Feedback"),
            AppCommonModel(image: UIImage(named: "ic_setting_4"), title: "Privacy policy"),
            AppCommonModel(image: UIImage(named: "ic_setting_5"), title: "Term & condition"),
            AppCommonModel(image: UIImage(named: "ic_setting_6"), title: "Restor Purchase")
        ]
        
        tableView.registerHeaderFooterView(of: SettingHeaderView.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
}


extension SettingVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingDeatils.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withType: SettingTBVCell.self)
        cell.img_view.image = settingDeatils[indexPath.row].image
        cell.lbl_title.text = settingDeatils[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            openAppStoreForRating()
        case 1:
            self.share(message: "", link: Constants.APP_URL)
        case 2:
            presentFeedbackMailComposer()
        case 3:
            openPrivacyPolicy()
        case 4:
            openTermCondition()
        case 5:
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
            self.pushVC(T: ProfileVC.instantiate(appStoryboard: .tabbar), viewControllerID: String(describing: ProfileVC.self ))
        }
        headerView.onTapSubscribeAction = {
            DispatchQueue.main.async {
                let vc = Constants.main_storyBoard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 360
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
                Constants.USERDEFAULTS.set(true, forKey: "pro")
                Constants.userSubscribeAvailable = true
                
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
                Constants.USERDEFAULTS.removeObject(forKey: "pro")
            }
        }
    }
}

extension SettingVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
