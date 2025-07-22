
import Foundation
import UIKit
import MapKit
import AVKit
import StoreKit
import ProgressHUD
import Toast_Swift
import Photos
import CoreHaptics
import SideMenuSwift

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

//MARK: - Get App release Version
func getAppInfo()-> Float {
    let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let appVersionInt = Float(appVersionString) ?? 0
    return appVersionInt
}

func formatDate(format:String? = "MM-dd-yyyy h:mm:ss a") -> String {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = format
    return timeFormatter.string(from: Date())
}

func goToHome() {
    let vc = StoryboardScene.TabBar.splashVC.instantiate()
    let nv = UINavigationController(rootViewController: vc)
    nv.isNavigationBarHidden = true
    
    // For SceneDelegate-based apps (iOS 13+)
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        window.rootViewController = nv
        window.makeKeyAndVisible()
    }
}

func goToOnboarding() {
    DispatchQueue.main.async {
        let vc = StoryboardScene.Main.introVC.instantiate()
        let nv = UINavigationController(rootViewController: vc)
        nv.isNavigationBarHidden = true
        
        // For SceneDelegate-based apps (iOS 13+)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nv
            window.makeKeyAndVisible()
        }
    }
}

func getTopMostViewController() -> UIViewController? {
    if #available(iOS 13.0, *) {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        var topMostViewController = keyWindow?.rootViewController

        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
    else {
        // Fallback for older iOS versions
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
}

func showLoader(text: String){
    DispatchQueue.main.async {
        ProgressHUD.animate(text, interaction: false)
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .maincolor
    }
}

func hideLoader(){
    DispatchQueue.main.async {
        ProgressHUD.dismiss()
    }
}

func showToastMessage(_ message: String) {
    DispatchQueue.main.async {
        var style = ToastStyle()
        style.backgroundColor = .maincolor
        style.messageColor = .white
        ToastManager.shared.style = style
        getTopMostViewController()?.view.makeToast(message,duration: 2.0, position: .top, style: style)
    }
}

func copyTextToClipboard(_ text: String) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = text
    showToastMessage("Copy clipboard")
}

func after(_ delay: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: completion)
}
