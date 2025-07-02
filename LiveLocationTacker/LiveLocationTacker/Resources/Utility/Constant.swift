//
//  Constant.swift
//  WhatsAppWeb
//
//  Created by DREAMWORLD on 09/12/23.
//

import Foundation
import UIKit

let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone

class Constants {
    
    public static let NetworkUnavailable = "Network unavailable. Please check your internet connectivity"
    static var NotificationPermission = false
    
    public static let USERDEFAULTS = UserDefaults.standard
    public static var ROOTVIEW = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
    
    //storyBoard
    //public static let main_storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
    //public static let tab_storyBoard = UIStoryboard(name: "TabBar", bundle:Bundle.main)
    
    //App Information
    public static let APP_ID = "6738461260"
    public static let APP_URL = "https://apps.apple.com/app/id\(Constants.APP_ID)"
    
    public static let RATE_URL = "\(Constants.APP_URL)" + "?action=write-review"
    public static let APP_NAME = "Phone Tracker : Family Locator"
    public static let FEEDBACK_MAILID = "tanavighinaiya@gmail.com"
    public static var MORE_APP_URL = ""
    
    public static var PRIVACY = "https://ikameinfotech.xyz/iPhoneTracker/iPhoneTrackerPrivacyPolicy.html"
    public static var TERMS = "https://ikameinfotech.xyz/iPhoneTracker/iPhoneTrackerTermConditions.html"
    
    //Revenucat
//    public static let REVANUE_API = ""
    public static let entitlementID = ""
    
    //AdS ID
    public static var INTERTIALS = ""
    public static var INTERTIALS2 = ""
    public static var OPEN = ""
    public static var OPEN2 = ""
    public static var NATIVE = ""
    public static var NATIVE2 = ""
    public static var BANNER:String = ""
    public static var BANNER2:String = ""
    
    public static var REWARDS:String = ""
    public static var NATIVE_BUTTON_COLOR:String = ""
    
    
    public static var Splash_adsShow = ""
    public static var Banner_adsShow = ""
    public static var Interstitial_adsShow = ""
    public static var Native_adsShow = ""
    public static var Appopen_adsShow = ""
    
    
    public static var firsttime_counter = Int()
    public static var firstTimeadsShow = false
    public static var ads_counter = Int()
    public static var adsCountInMemory = 1
    
    public static var ads_visibility:String = ""
    public static var Intro_Purchase_Ads:String = ""
    
    public static var ios_version = ""
    public static var force_update = ""
    
    public static var isForApple = false
    public static var freeTrailActive = false
    
    public static let device_type = "iOS"
    //public static var userSubscribeAvailable:Bool = false
    public static var isFromSubscibeScreen = false
    
    //API
    public static let SPLASH_API = "https://narolaapps.xyz/ios_test.json"
    static var FCM_USER_TOKEN = ""
}


struct AppFont {

    public static let regular = "Poppins-Regular"
    public static let medium = "Poppins-Medium"
    public static let semiBold = "Poppins-SemiBold"
    public static let bold = "Poppins-Bold"
    
    struct Size {
        public static let light: CGFloat = 12.0
        public static let small: CGFloat = 14.0
        public static let medium: CGFloat = 18.0
        public static let medium20: CGFloat = 20.0
        public static let large: CGFloat = 24.0
        public static let xlarge: CGFloat = 36.0
    }
    
    // Convenience methods to get UIFont objects
    static func regular(size: CGFloat) -> UIFont? {
        return UIFont(name: regular, size: size)
    }
    
    static func medium(size: CGFloat) -> UIFont? {
        return UIFont(name: medium, size: size)
    }
    
    static func semiBold(size: CGFloat) -> UIFont? {
        return UIFont(name: semiBold, size: size)
    }
    
    static func bold(size: CGFloat) -> UIFont? {
        return UIFont(name: bold, size: size)
    }
}

