//
//  DefaultManager.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//
import Foundation
class DefaultManager {
    
    private static let defaults = UserDefaults.standard
    
    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
    }
    
    static var selectedLanguage: LanguageType {
        get { LanguageType(rawValue: defaults.integer(forKey: Keys.selectedLanguage)) ?? .NONE }
        set { defaults.set(newValue.rawValue, forKey: Keys.selectedLanguage) }
    }
    
    static func removeAll() {
        DefaultManager.IS_INITIAL_SETUP = false
        DefaultManager.User.COUNTRY_CODE = ""
        DefaultManager.User.PHONE = ""
        DefaultManager.User.FIRST_NAME = ""
        DefaultManager.User.LAST_NAME = ""
        DefaultManager.User.GENDER = ""
        DefaultManager.User.PROFILE_PIC = ""
    }
    
    static var IS_SUBSCRIPTION: Bool {
        get {
            return false//(UserDefaults.standard.bool(forKey: #function))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var IS_INITIAL_SETUP: Bool {
        get {
            return (UserDefaults.standard.bool(forKey: #function))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
            UserDefaults.standard.synchronize()
        }
    }
    
    struct User {
        static func setupUserInfo(info: UserInfo) {
            DefaultManager.User.COUNTRY_CODE = "\(info.countryCode)"
            DefaultManager.User.PHONE = info.phone
            DefaultManager.User.FIRST_NAME = info.firstName
            DefaultManager.User.LAST_NAME = info.lastName
            DefaultManager.User.GENDER = info.gender
            DefaultManager.User.PROFILE_PIC = info.profilePic
            //DefaultManager.User.PROFILE_DATA = nil
            //DefaultManager.User.IS_CHILD_MODE_ENABLE = info.childMode.enabled == 1
            DefaultManager.User.CHILD_MODE_CODE = AppData.shared.activeChildCircle.code//info.childMode.code
            DefaultManager.User.CHILD_MODE_OWNER_PHONE = AppData.shared.activeChildCircle.ownerPhone//info.childMode.ownerPhone
        }
        
        static var COUNTRY_CODE: String {
            get {
                return (UserDefaults.standard.string(forKey: #function) ?? "91")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var PHONE: String {
            get {
                return (UserDefaults.standard.string(forKey: #function) ?? "")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var NAME: String {
            get {
                return getFullName(firstName: FIRST_NAME, lastName: LAST_NAME)
            }
        }
        
        static var FIRST_NAME: String {
            get {
                return (UserDefaults.standard.string(forKey: #function) ?? "")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var LAST_NAME: String {
            get {
                return (UserDefaults.standard.string(forKey: #function) ?? "")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var GENDER: String {
            get {
                return (UserDefaults.standard.string(forKey: #function) ?? "")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var PROFILE_PIC: String {
            get {
                return (UserDefaults.standard.string(forKey: #function) ?? "")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        /*static var PROFILE_DATA: Data? {
            get {
                return (UserDefaults.standard.data(forKey: #function))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }*/
        
        static var FCM_TOKEN: String {
            get {
                return (UserDefaults.standard.string(forKey: #function) ?? "")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var IS_CHILD_MODE_ENABLE: Bool {
            get {
                return (UserDefaults.standard.bool(forKey: #function))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var CHILD_MODE_CODE: String {
            get {
                return (UserDefaults.standard.string(forKey: #function) ?? "")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var CHILD_MODE_OWNER_PHONE: String {
            get {
                return (UserDefaults.standard.string(forKey: #function) ?? "")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    struct Permission {
        static var LOCATION: Bool {
            get {
                return (UserDefaults.standard.bool(forKey: #function))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var BATTERY: Bool {
            get {
                return (UserDefaults.standard.bool(forKey: #function))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var NOTIFICATION: Bool {
            get {
                return (UserDefaults.standard.bool(forKey: #function))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var PROXIMITY_NOTIFICATION: Bool {
            get {
                return (UserDefaults.standard.bool(forKey: #function))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var CAMERA: Bool {
            get {
                return (UserDefaults.standard.bool(forKey: #function))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var MOTION: Bool {
            get {
                return (UserDefaults.standard.bool(forKey: #function))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    struct Cirlce {
        static var CURRENT_CODE: String {
            get {
                return UserDefaults.standard.string(forKey: #function) ?? ""
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
            }
        }
 
    }
    
    //MARK: PUSH NOTIFICATION
    struct NotificationSettings {
        static var notificationType: Int {
            get {
                return (UserDefaults.standard.integer(forKey: #function))
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
                UserDefaults.standard.synchronize()
            }
        }
        
        static var userInfo: [AnyHashable: Any] {
            get {
                if let data = UserDefaults.standard.data(forKey: #function) {
                    if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] {
                        return dict
                    }
                }
                return [:]
            }
            set {
                if let data = try? JSONSerialization.data(withJSONObject: newValue, options: []) {
                    UserDefaults.standard.set(data, forKey: #function)
                    UserDefaults.standard.synchronize()
                }
            }
        }
        
    }

}
