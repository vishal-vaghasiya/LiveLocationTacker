//
//  CircleInfo.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//

class CircleInfo {
    var code: String
    var members: [String]
    var childMember: [String]
    var name: String
    var childName: String
    var childProfile: String
    var ownerPhone: String
    var timestamp: Int
    
    init(dictionary: [String: Any]) {
        self.code = dictionary[FirebaseKeys.code] as? String ?? ""
        self.name = dictionary[FirebaseKeys.name] as? String ?? ""
        self.childName = ""
        self.childProfile = ""
        self.ownerPhone = "\(dictionary[FirebaseKeys.ownerPhone] ?? "")"
        self.timestamp = dictionary[FirebaseKeys.timestamp] as? Int ?? 0
        
        // Extract member phone numbers into array
        if let membersDict = dictionary[FirebaseKeys.members] as? [String: Any] {
            self.members = membersDict.compactMap { (_, value) in
                if let memberData = value as? [String: Any] {
                    return "\(memberData[FirebaseKeys.phone] ?? "")"
                }
                return nil
            }
        } else {
            self.members = []
        }
        
        // Extract member phone numbers into array
        if let membersDict = dictionary[FirebaseKeys.childNumber] as? [String: Any] {
            self.childMember = membersDict.compactMap { (_, value) in
                if let memberData = value as? [String: Any] {
                    return "\(memberData[FirebaseKeys.phone] ?? "")"
                }
                return nil
            }
        } else {
            self.childMember = []
        }
    }
    
    // ✅ Default empty initializer
    init() {
        self.code = ""
        self.members = []
        self.childMember = []
        self.name = ""
        self.childName = ""
        self.childProfile = ""
        self.ownerPhone = ""
        self.timestamp = 0
    }
}

//MARK
/*
 let circles = snapshots.compactMap { snapshot -> CircleInfo? in
 guard let dict = snapshot.value as? [String: Any] else { return nil }
 return CircleInfo(dictionary: dict)
 }
 */

/*
 let circleModel = CircleInfo(dictionary: dict)
 circles.append(circleModel)
 */
