//
//  UserInfo.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 10/07/25.
//

import Foundation

class UserInfo {
    var gender: String
    var batteryLevel: Int
    var countryCode: Int
    var latitude: Double
    var timestamp: Int
    var longitude: Double
    var phone: String
    var name: String
    var fcmtoken: String
    var address: String
    var profilePic: String

    var childMode: ChildMode
    
    init(dictionary: [String: Any]) {
        self.gender = dictionary[FirebaseKeys.gender] as? String ?? ""
        self.batteryLevel = dictionary[FirebaseKeys.batteryLevel] as? Int ?? 0
        self.countryCode = dictionary[FirebaseKeys.countryCode] as? Int ?? 0
        self.latitude = dictionary[FirebaseKeys.latitude] as? Double ?? 0.0
        self.timestamp = dictionary[FirebaseKeys.timestamp] as? Int ?? 0
        self.longitude = dictionary[FirebaseKeys.longitude] as? Double ?? 0.0
        self.phone = dictionary[FirebaseKeys.phone] as? String ?? ""
        self.name = dictionary[FirebaseKeys.name] as? String ?? ""
        self.fcmtoken = dictionary[FirebaseKeys.fcmtoken] as? String ?? ""
        self.address = dictionary[FirebaseKeys.address] as? String ?? ""
        self.profilePic = dictionary[FirebaseKeys.profilePicture] as? String ?? ""
        
        if let childModeDict = dictionary[FirebaseKeys.childMode] as? [String: Any] {
            self.childMode = ChildMode(dictionary: childModeDict)
        } else {
            self.childMode = ChildMode()
        }
    }
}

class ChildMode {
    var code : String
    var enabled : Int
    var ownerPhone : String
    
    init(dictionary: [String: Any]) {
        self.code = dictionary[FirebaseKeys.code] as? String ?? ""
        self.enabled = dictionary[FirebaseKeys.enabled] as? Int ?? 0
        self.ownerPhone = dictionary[FirebaseKeys.ownerPhone] as? String ?? ""
    }
    
    // ✅ Default empty initializer
    init() {
        self.code = ""
        self.enabled = 0
        self.ownerPhone = ""
    }
}

func parseUsers(from data: [[String: Any]]) -> [UserInfo] {
    return data.map { UserInfo(dictionary: $0) }
}
