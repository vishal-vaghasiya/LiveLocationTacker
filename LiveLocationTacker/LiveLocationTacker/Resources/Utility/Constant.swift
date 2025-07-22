//
//  Constant.swift
//
//  Created by DREAMWORLD on 09/12/23.
//

import Foundation
import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad

let APP_ID = "6748630610"
let APP_URL = "https://apps.apple.com/app/id\(APP_ID)"

let RATE_URL = "\(APP_URL)?action=write-review"
let APP_NAME = "Family Locator : Phone Tracker"
let FEEDBACK_MAILID = "tanavighinaiya@gmail.com"
var MORE_APP_URL = ""

var PRIVACY = "https://ikameinfotech.xyz/iPhoneTracker/iPhoneTrackerPrivacyPolicy.html"
var TERMS = "https://ikameinfotech.xyz/iPhoneTracker/iPhoneTrackerTermConditions.html"

let DEVICE_TYPE = "iOS"

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
    static let userDefault = UserDefaults.standard
    static let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    static let window = (UIApplication.shared.delegate as! AppDelegate).window
    static let windows = UIApplication.shared.windows.first
    static let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    static let fileManager = FileManager.default
}
