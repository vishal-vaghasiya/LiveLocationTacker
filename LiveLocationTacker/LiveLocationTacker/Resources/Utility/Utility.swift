
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

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

func isIpad() -> Bool {
    if( UIDevice.current.userInterfaceIdiom == .pad) {
        return true
    }
    return false
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
