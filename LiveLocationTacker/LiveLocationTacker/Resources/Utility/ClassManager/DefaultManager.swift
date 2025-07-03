//
//  DefaultManager.swift
//  InterviewTask
//
//  Created by d3vil_mind on 03/08/21.
//

import Foundation

class DefaultManager {

    static var IS_SUBSCRIPTION: Bool {
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
    
    // Mobile Number
//    func saveCurrentuserNumber(value: String) {
//        set(value, forKey: UserDefaultsKeys.save_mobilenumer.rawValue)
//    }
//    
//    func getCurrentuserNumber() -> String {
//        return string(forKey: UserDefaultsKeys.save_mobilenumer.rawValue) ?? ""
//    }
//    
//    func removeCurrentUserNumber() {
//        removeObject(forKey: UserDefaultsKeys.save_mobilenumer.rawValue)
//    }
    
    // User Name
//    func saveCurrentuserName(value: String) {
//        set(value, forKey: UserDefaultsKeys.save_name.rawValue)
//    }
//    
//    func getCurrentuserName() -> String {
//        return string(forKey: UserDefaultsKeys.save_name.rawValue) ?? ""
//    }
//    
//    func removeCurrentUserName() {
//        removeObject(forKey: UserDefaultsKeys.save_name.rawValue)
//    }
    
    // User Geneder
//    func saveCurrentuserGender(value: String) {
//        set(value, forKey: UserDefaultsKeys.save_gender.rawValue)
//    }
//    
//    func getCurrentuserGender() -> String {
//        return string(forKey: UserDefaultsKeys.save_gender.rawValue) ?? ""
//    }
//    
//    func removeCurrentUserGender() {
//        removeObject(forKey: UserDefaultsKeys.save_gender.rawValue)
//    }
    
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
    
    // Location Sharing
//    func saveLocationSharing(value: Bool) {
//        set(value, forKey: UserDefaultsKeys.location_sharing.rawValue)
//    }
//    
//    func getLocationSharing() -> Bool {
//        return bool(forKey: UserDefaultsKeys.location_sharing.rawValue)
//    }
//    
//    func removeLocationSharing() {
//        removeObject(forKey: UserDefaultsKeys.location_sharing.rawValue)
//    }
    
    // Battery Sharing
//    func saveBatterySharing(value: Bool) {
//        set(value, forKey: UserDefaultsKeys.battery_sharing.rawValue)
//    }
//    
//    func getBatterySharing() -> Bool {
//        return bool(forKey: UserDefaultsKeys.battery_sharing.rawValue)
//    }
//    
//    func removeBatterySharing() {
//        removeObject(forKey: UserDefaultsKeys.battery_sharing.rawValue)
//    }
    
    // Notification Sharing
//    func saveNotificationSharing(value: Bool) {
//        set(value, forKey: UserDefaultsKeys.notification_sharing.rawValue)
//    }
//    
//    func getNotificationSharing() -> Bool {
//        return bool(forKey: UserDefaultsKeys.notification_sharing.rawValue)
//    }
//    
//    func removeNotificationSharing() {
//        removeObject(forKey: UserDefaultsKeys.notification_sharing.rawValue)
//    }
    
    // Camera Permission
//    func saveCameraSharing(value: Bool) {
//        set(value, forKey: UserDefaultsKeys.camera_sharing.rawValue)
//    }
//    
//    func getCameraSharing() -> Bool {
//        return bool(forKey: UserDefaultsKeys.camera_sharing.rawValue)
//    }
//    
//    func removeCameraSharing() {
//        removeObject(forKey: UserDefaultsKeys.camera_sharing.rawValue)
//    }
    
    // Motion Permission
//    func saveMotionSharing(value: Bool) {
//        set(value, forKey: UserDefaultsKeys.motion_sharing.rawValue)
//    }
//    
//    func getMotionSharing() -> Bool {
//        return bool(forKey: UserDefaultsKeys.motion_sharing.rawValue)
//    }
//    
//    func removeMotionSharing() {
//        removeObject(forKey: UserDefaultsKeys.motion_sharing.rawValue)
//    }
    
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
    
    // FCM token
//    func saveFCMToken(value: String) {
//        set(value, forKey: UserDefaultsKeys.fcm_token.rawValue)
//    }
//
//    func getFCMToken() -> String {
//        return string(forKey: UserDefaultsKeys.fcm_token.rawValue) ?? ""
//    }
//
//    func removeFCMToken() {
//        removeObject(forKey: UserDefaultsKeys.fcm_token.rawValue)
//    }

}

