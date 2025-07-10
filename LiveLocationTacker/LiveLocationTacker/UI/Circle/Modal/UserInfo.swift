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

    init(dictionary: [String: Any]) {
        self.gender = dictionary["gender"] as? String ?? ""
        self.batteryLevel = dictionary["battery_level"] as? Int ?? 0
        self.countryCode = dictionary["country_code"] as? Int ?? 0
        self.latitude = dictionary["latitude"] as? Double ?? 0.0
        self.timestamp = dictionary["timestamp"] as? Int ?? 0
        self.longitude = dictionary["longitude"] as? Double ?? 0.0
        self.phone = dictionary["phone"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.fcmtoken = dictionary["fcmtoken"] as? String ?? ""
        self.address = dictionary["address"] as? String ?? ""
        self.profilePic = dictionary["profile_pic"] as? String ?? ""
    }
}

func parseUsers(from data: [[String: Any]]) -> [UserInfo] {
    return data.map { UserInfo(dictionary: $0) }
}
