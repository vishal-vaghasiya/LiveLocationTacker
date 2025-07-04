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
        DefaultManager.User.PROFILE_PIC = ""
        DefaultManager.User.PROFILE_DATA = nil
        DefaultManager.Permission.LOCATION = false
        DefaultManager.Permission.BATTERY = false
        DefaultManager.Permission.NOTIFICATION = false
        DefaultManager.Permission.CAMERA = false
        DefaultManager.Permission.MOTION = false
        DefaultManager.Cirlce.CURRENT_CODE = ""
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
        
        static var PROFILE_DATA: Data? {
            get {
                return (UserDefaults.standard.data(forKey: #function))
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
    
}
