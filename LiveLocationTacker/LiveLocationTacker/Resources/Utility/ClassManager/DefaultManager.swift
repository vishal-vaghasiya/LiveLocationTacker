//
//  DefaultManager.swift
//  InterviewTask
//
//  Created by d3vil_mind on 03/08/21.
//

import Foundation

class DefaultManager {
    
    static func removeAll() {
        //        UserDefaults.standard.dictionaryRepresentation().keys.forEach {
        //            UserDefaults.standard.removeObject(forKey: $0)
        //        }
        DefaultManager.IS_INITIAL_SETUP = false
        DefaultManager.User.COUNTRY_CODE = ""
        DefaultManager.User.PHONE = ""
        DefaultManager.User.NAME = ""
        DefaultManager.User.GENDER = ""
        DefaultManager.Permission.LOCATION = false
        DefaultManager.Permission.BATTERY = false
        DefaultManager.Permission.NOTIFICATION = false
        DefaultManager.Permission.CAMERA = false
        DefaultManager.Permission.MOTION = false
        Constants.USERDEFAULTS.removeCurrentUserCode()
        Constants.USERDEFAULTS.removeProfileImage()
    }
    
    static var IS_SUBSCRIPTION: Bool {
        get {
            return (UserDefaults.standard.bool(forKey: #function))
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
        
        static var FCM_TOKEN: String {
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
    
}

enum UserDefaultsKeys : String {
    case save_mobilenumer
    case save_name
    case save_gender
    case save_code
    case location_sharing
    case battery_sharing
    case notification_sharing
    case camera_sharing
    case motion_sharing
    case profile_img
    case fcm_token
}

extension UserDefaults {
    
    // User Code
    func saveCurrentuserCode(value: String) {
        set(value, forKey: UserDefaultsKeys.save_code.rawValue)
    }
    
    func getCurrentuserCode() -> String {
        return string(forKey: UserDefaultsKeys.save_code.rawValue) ?? ""
    }
    
    func removeCurrentUserCode() {
        removeObject(forKey: UserDefaultsKeys.save_code.rawValue)
    }
    
    // Profile Image
    func saveProfileImage(value: Data) {
        set(value, forKey: UserDefaultsKeys.profile_img.rawValue)
    }
    
    func getProfileImage() -> Data? {
        return data(forKey: UserDefaultsKeys.profile_img.rawValue)
    }
    
    func removeProfileImage() {
        removeObject(forKey: UserDefaultsKeys.profile_img.rawValue)
    }
    
}

