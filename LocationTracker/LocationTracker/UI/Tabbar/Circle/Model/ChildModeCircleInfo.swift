//
//  ChildModeCircleInfo.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//

class ChildModeCircleInfo {
    var code: String
    var ownerPhone: String
    var circleName: String
    var member: Int
    var childPhone: String
    var childName: String
    var childProfile: String
    
    // ✅ Default empty initializer
    init() {
        self.code = ""
        self.ownerPhone = ""
        self.circleName = ""
        self.member = 0
        
        self.childPhone = ""
        self.childName = ""
        self.childProfile = ""
    }
}
