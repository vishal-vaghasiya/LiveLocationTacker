//
//  Constant.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit

let AppName = "Phone Tracker — Family Locator"
let AppID = "6748630610"
let AppURL = "https://apps.apple.com/app/id" + AppID

let RateURL = AppURL + "?action=write-review"
let FeedbackMailID = "ghinaiyaamit@icloud.com"

let Privacy_Policy = "https://gdmarthome.com/PhoneTracker/PrivacyPolicy.html"
let Terms_Condition = "https://gdmarthome.com/PhoneTracker/TermConditions.html"

let DeviceType = "iOS"

var isComeFromLogin: Bool = false

var rootController: UIViewController? {
    return UIApplication
        .shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?
        .rootViewController
}

internal enum VariableInfo { }
internal extension VariableInfo {
    static let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    static var appWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow })
    }
}
