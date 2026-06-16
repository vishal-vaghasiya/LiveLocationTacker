//
//  Utility.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import Foundation
import UIKit
import Toast_Swift
import ProgressHUD
import SafariServices

public func print(_ object: Any...) {
    #if DEBUG
    for item in object {
        if JSONSerialization.isValidJSONObject(item) {
            do {
                // Convert valid JSON objects to pretty-printed JSON
                let jsonData = try JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    Swift.print(jsonString) // Print JSON in readable format
                } else {
                    Swift.print(item)
                }
            } catch {
                Swift.print(item)
            }
        } else {
            Swift.print(item)
        }
    }
    #endif
}

func after(_ delay: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: completion)
}

func main(completion:@escaping()->()){
    DispatchQueue.main.async {
        completion()
    }
}

public var appLanguageBundle: Bundle {
    if let path = Bundle.main.path(forResource: DefaultManager.selectedLanguage.langCode, ofType: "lproj"),
       let langBundle = Bundle(path: path) {
        return langBundle
    }
    return Bundle.main
}

func goToDashboard() {
    DispatchQueue.main.async {
        let vc = StoryboardScene.TabBar.mainTabBarController.instantiate()
        VariableInfo.appWindow?.rootViewController = vc
    }
}

func goToWelcome() {
    DispatchQueue.main.async {
        let vc = StoryboardScene.Main.welcomeVC.instantiate()
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        VariableInfo.appWindow?.rootViewController = nav
    }
}

func showToast(message: String) {
    DispatchQueue.main.async {
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = Asset.appBlack.color
        toastStyle.messageColor = .white
        
        ToastManager.shared.style = toastStyle
        
        rootController?.view.makeToast(
            message,
            duration: 2.0,
            position: .top,
            style: toastStyle
        )
    }
}

func copyToClipboard(text: String) {
    UIPasteboard.general.string = text
    showToast(message: "Copied to clipboard")
}

enum Loader {
    
    static func show(_ message: String) {
        DispatchQueue.main.async {
            ProgressHUD.animationType = .circleStrokeSpin
            ProgressHUD.colorAnimation = Asset.appBlack.color
            ProgressHUD.animate(message, interaction: false)
        }
    }
    
    static func hide() {
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
        }
    }
}

func shareContent(message: String? = nil, link: String? = nil, from sourceView: UIView? = nil) {
    var itemsToShare: [Any] = []
    
    // Add message if available
    if let message = message, !message.isEmpty {
        itemsToShare.append(message)
    }
    
    // Add link if available and valid
    if let link = link, let url = URL(string: link) {
        itemsToShare.append(url)
    }
    
    // If nothing to share, exit early
    guard !itemsToShare.isEmpty else {
        print("⚠️ Nothing to share")
        return
    }
    
    let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
    
    // iPad: Present as popover
    if let popoverController = activityVC.popoverPresentationController, let sourceView = sourceView {
        popoverController.sourceView = sourceView
        popoverController.sourceRect = sourceView.bounds
        popoverController.permittedArrowDirections = [.up, .down]
    }
    
    DispatchQueue.main.async {
        if let topVC = UIApplication.shared.topMostViewController() {
            topVC.present(activityVC, animated: true)
        }
    }
}

func openAppStorePageForRating() {
    guard let appStorePageURL = URL(string: RateURL) else {
        print("❌ Invalid App Store URL: \(RateURL)")
        return
    }
    
    UIApplication.shared.open(appStorePageURL, options: [:]) { isSuccess in
        if isSuccess {
            print("✅ App Store opened successfully")
        } else {
            print("⚠️ Failed to open App Store URL: \(appStorePageURL)")
        }
    }
}


func presentPrivacyPolicy(from presenter: UIViewController) {
    guard let privacyPolicyURL = URL(string: Privacy_Policy) else {
        print("❌ Invalid Privacy Policy URL: \(Privacy_Policy)")
        return
    }
    
    let safariViewController = SFSafariViewController(url: privacyPolicyURL)
    safariViewController.modalPresentationStyle = .fullScreen
    
    DispatchQueue.main.async {
        presenter.present(safariViewController, animated: true)
    }
}

func presentTermsAndConditions(from presenter: UIViewController) {
    guard let termsURL = URL(string: Terms_Condition) else {
        print("❌ Invalid Terms & Conditions URL: \(Terms_Condition)")
        return
    }
    
    let safariViewController = SFSafariViewController(url: termsURL)
    safariViewController.modalPresentationStyle = .fullScreen
    
    DispatchQueue.main.async {
        presenter.present(safariViewController, animated: true)
    }
}

func setUpBattery(batteryLevel: Int) -> (String, UIColor, UIImage) {
    let value0 = "\(batteryLevel)%"
    var value1 = UIColor.systemGreen
    if batteryLevel >= 80 {
        value1 = Asset.appMain.color//.systemGreen
        return (value0, value1, Asset.iconBattery.image)
    } else if batteryLevel <= 20 {
        value1 = Asset.appMain.color//.systemRed
        return (value0, value1, Asset.iconBattery.image)
    } else {
        value1 = Asset.appMain.color//.systemOrange
        return (value0, value1, Asset.iconBattery.image)
    }
}

func formatDate(format:String? = "MM-dd-yyyy h:mm:ss a") -> String {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = format
    return timeFormatter.string(from: Date())
}

func getPin(type: String) -> (UIImage, UIImage) {
    switch type {
    case "1":
        return (Asset.pinHome.image, Asset.proxiTypeHome.image)
    case "2":
        return (Asset.pinGym.image, Asset.proxiTypeGym.image)
    case "3":
        return (Asset.pinOffice.image, Asset.proxiTypeOffice.image)
    case "4":
        return (Asset.pinShop.image, Asset.proxiTypeShop.image)
    case "5":
        return (Asset.pinEducation.image, Asset.proxiTypeEducation.image)
    case "6":
        return (Asset.pinHospital.image, Asset.proxiTypeHospital.image)
    default:
        return (Asset.pinOther.image, Asset.proxiTypeOther.image)
    }
}

func getFullName(firstName: String?, lastName: String?) -> String {
    let first = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let last = lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return [first, last].filter { !$0.isEmpty }.joined(separator: " ")
}

func getTopVc(base: UIViewController?) -> UIViewController {
    if let nav = base as? UINavigationController, let vc = nav.visibleViewController {
        if let presented = vc.presentedViewController {
            return presented
        } else {
            return vc
        }
    } else {
        return UIViewController()
    }
}
