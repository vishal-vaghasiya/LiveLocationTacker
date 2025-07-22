//
//  Helper+UIViewController.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 04/07/25.
//

import UIKit
import ProgressHUD
import Toast_Swift

extension UIViewController {
    
    func navigateToHome() {
        DispatchQueue.main.async { [self] in
            let vc = StoryboardScene.TabBar.homeTabVC.instantiate()
            self.view.window?.rootViewController = vc
        }
    }
    
    func navigateToOnboarding() {
        DispatchQueue.main.async {
            let vc = StoryboardScene.Main.introVC.instantiate()
            let nv = UINavigationController(rootViewController: vc)
            nv.isNavigationBarHidden = true
            self.view.window?.rootViewController = nv
        }
    }
    
    func showAlert(title : String, message : String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlertForNoInternetConnection() {
        DispatchQueue.main.async { [self] in
            let alertController = UIAlertController(title: "No Internet", message: "Please check you internet connection", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlertPermission(title : String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let settingAction = UIAlertAction(title: "Setting", style: .default, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        })
        alertController.addAction(okAction)
        alertController.addAction(settingAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func share(message: String, link: String, sourceView: UIView? = nil) {
        if let url = NSURL(string: link) {
            let objectsToShare = [message, url] as [Any]
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                // For iPad, present the activity view controller as a popover
                if let popoverController = activityVC.popoverPresentationController, let sourceView = sourceView {
                    popoverController.sourceView = sourceView
                    popoverController.sourceRect = sourceView.bounds
                    popoverController.permittedArrowDirections = [.up, .down]
                }
                
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func openNotification(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            if DefaultManager.NotificationSettings.notificationType == 2 {
                let vc = StoryboardScene.ChildMode.popupInviteChildMode.instantiate()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true) {
                    DefaultManager.NotificationSettings.notificationType = 0
                }
            }
        })
    }
}
