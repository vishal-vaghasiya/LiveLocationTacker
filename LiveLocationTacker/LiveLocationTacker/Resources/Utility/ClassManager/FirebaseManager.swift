//
//  FirebaseManager.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 15/11/24.
//

import Foundation
import FirebaseDatabase
import CoreLocation
import SwiftJWT
import FirebaseAuth
import FirebaseStorage
import FirebaseAnalytics

struct GoogleJWTClaims: Claims {
    let iss: String // Issuer (email from service account)
    let scope: String
    let aud: String
    let exp: Int
    let iat: Int
}

enum NotificationType: Int {
    case none = 0
    case sos = 1
    case disableChildMode = 2
    
    var description: String {
        switch self {
        case .none:
            return "NONE"
        case .sos:
            return "SOS"
        case .disableChildMode:
            return "Disable Child Mode"
        }
    }
}

enum FirebaseTableName: String {
    case users = "users"
    case circle = "circles"
    case locations = "locations"
    
    var name: String {
#if DEBUG
        return self.rawValue + "_dev"
#else
        return self.rawValue
#endif
    }
}

// MARK: - Firebase Manager (Singleton)
class FirebaseManager {
    
    static let shared = FirebaseManager()
    let ref: DatabaseReference
    
    private init() {
        ref = Database.database().reference()
    }
    
    func logAnalyticsEvent(name eventName: AnalyticsEventName, parameters: [String: Any] = [:]) {
        Analytics.logEvent(eventName.rawValue, parameters: parameters)
    }
    
    // MARK: - Firebase OTP Operations
    
    /// Send OTP to the provided phone number
    func sendMobileOTP(phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("Error sending OTP: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            // Save verification ID
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            completion(true, "OTP sent successfully")
        }
    }
    
    /// Resend OTP to the provided phone number
    func resendOTP(phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                completion(false ,"Error resending OTP: \(error.localizedDescription)")
                return
            }
            
            // Save new verification ID
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            completion(true, "OTP resent successfully")
        }
    }
    
    /// Verify OTP with the verification code
    func verifyOTP(otpCode: String, completion: @escaping (Bool, String?) -> Void) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            print("No verification ID found.")
            completion(false ,"No verification ID found.")
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: otpCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("OTP verification failed: \(error.localizedDescription)")
                completion(false ,"OTP verification failed: \(error.localizedDescription)")
                return
            }
            completion(true ,"Phone number verified successfully!")
            // Proceed to next screen
        }
    }
    
    //MARK: - Save user to Firebase Realtime Database
    func checkAndSaveUser(phoneNumber: String, param: [String: Any], completion: @escaping (Bool, String, [String: Any]?) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let currentUser = Auth.auth().currentUser else {
            goToOnboarding()
            completion(false, "User is not authenticated.", nil)
            return
        }
        
        print("Authenticated UID: \(currentUser.uid)")
        
        let userRef = ref.child(FirebaseTableName.users.name).child(phoneNumber)
        
        // First: Check if user exists
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let userData = snapshot.value as? [String: Any] {
                // User already exists
                completion(true, "User already exists.", userData)
            } else {
                // User doesn't exist, save user
                userRef.setValue(param) { error, _ in
                    if let error = error {
                        completion(false, error.localizedDescription, nil)
                    } else {
                        DefaultManager.User.PHONE = param[FirebaseKeys.phone] as? String ?? ""
                        self.createCircle(name: "My Circle") { success, message, data in
                            completion(true, "User registered successfully.", param)
                        }
                    }
                }
            }
        }
    }
    
    func updateUserData(updatedValues: [String: Any], completion: @escaping (Bool, String) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            completion(false, "User is not authenticated.")
            return
        }
        
        let userRef = ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)
        
        var param = updatedValues
        param[FirebaseKeys.timestamp] = Date().getCurrentUTCTimestampInfo().timestampSeconds
        
        userRef.updateChildValues(param) { error, _ in
            if let error = error {
                print("Error updating user: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            } else {
                print("User data updated successfully.")
                completion(true, "User data updated successfully.")
            }
        }
    }
    
    //MARK: Example:
    /*LocationManager.shared.getCurrentLocation { location in
        LocationManager.shared.getGoogleAddress(lat: location.coordinate.latitude, long: location.coordinate.longitude) { address in
            let param: [String: Any] = [
                "name": "Vishal Vaghasiya",
                "gender": "male",
                "country_code": "91",
                "phone": "9725992972",
                "profile_pic": "",
                "battery_level": 100,
                "fcmtoken": DefaultManager.User.FCM_TOKEN,
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "address": address ?? "N/A",
                "timestamp": Date().getCurrentUTCTimestampInfo().timestampSeconds
            ]
            FirebaseManager().checkAndSaveUser(phoneNumber: "9725992972", param: param) { success, message, userData  in
                print(message)
                if let user = userData {
                    print("User Data: \(user)")
                }
                
                let updatedData: [String: Any] = [
                    "name": "Vishal Vaghasiya",
                    "timestamp": Date().getCurrentUTCTimestampInfo().timestampSeconds
                ]
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    FirebaseManager().updateUserData(phoneNumber: "9725992972", updatedValues: updatedData) { success, message in
                        print(message)
                    }
                })
            }
        }
    }*/
    
    // MARK: - Fetch User Data
    func fetchUserData(completion: @escaping (Result<UserInfo, Error>, String) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated."])
            completion(.failure(error), "User is not authenticated.")
            return
        }
        
        let userRef = ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let userData = snapshot.value as? [String: Any] {
                DefaultManager.User.setupUserInfo(info: UserInfo(dictionary: userData))
                completion(.success(UserInfo(dictionary: userData)), "User data fetched successfully.")
            } else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found."])
                print("⚠️ User data not found.")
                completion(.failure(error), "User data not found.")
            }
        } withCancel: { error in
            print("❌ Failed to fetch user data: \(error.localizedDescription)")
            completion(.failure(error), error.localizedDescription)
        }
    }
    //MARK: Example:
    /*
     fetchUserData(byPhoneNumber: DefaultManager.User.PHONE) { result, message in
         switch result {
         case .success(let userData):
             // Handle success here
             print("User Data: \(userData)")
         case .failure(let error):
             // Handle error here
             print("Error: \(error.localizedDescription)")
         }
     }
     */
     
    // MARK: - Fetch Multiple Users by Phone Numbers
    func fetchUsersData(phoneNumbers: [String], completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated."])
            completion(.failure(error))
            return
        }
        
        let usersRef = ref.child(FirebaseTableName.users.name)
        var usersArray: [[String: Any]] = []
        var errors: [Error] = []
        let dispatchGroup = DispatchGroup()
        
        for phone in phoneNumbers {
            dispatchGroup.enter()
            usersRef.child(phone).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(), let userData = snapshot.value as? [String: Any] {
                    usersArray.append(userData)
                } else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found for phone: \(phone)"])
                    errors.append(error)
                }
                dispatchGroup.leave()
            } withCancel: { error in
                errors.append(error)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !usersArray.isEmpty {
                completion(.success(usersArray))
            } else if let firstError = errors.first {
                print("❌ Failed to fetch any users.")
                completion(.failure(firstError))
            } else {
                let error = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred."])
                completion(.failure(error))
            }
        }
    }
    
    //MARK: Example:
    /*
     let phoneNumbers = ["123456897", "12345677890"]

     fetchUsersData(phoneNumbers: phoneNumbers) { result in
         switch result {
         case .success(let users):
             print("Fetched Users: \(users)")
         case .failure(let error):
             print("Error: \(error.localizedDescription)")
         }
     }
     */
    
    //MARK: - Get User info
    func fetchUserData(phoneNumber: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated."])
            completion(.failure(error))
            return
        }
        
        let userRef = ref.child(FirebaseTableName.users.name).child(phoneNumber)
        
        userRef.observeSingleEvent(of: .value) { snapshot  in
            if let userData = snapshot.value as? [String: Any] {
                do {
                    let user = UserInfo(dictionary: userData)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found."])
                completion(.failure(error))
            }
        } withCancel: { error in
            completion(.failure(error))
        }
    }
    
    //MARK: EXAMPLE::
    /*
     fetchUserData(phoneNumber: "9876543210") { result in
         switch result {
         case .success(let user):
             print("User fetched: \(user)")
         case .failure(let error):
             print("Error: \(error.localizedDescription)")
         }
     }
     */
    
    // MARK: - Fetch FCM Tokens by Phone Numbers
    func fetchUsersFCMTokens(phoneNumbers: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated."])
            completion(.failure(error))
            return
        }
        
        let usersRef = ref.child(FirebaseTableName.users.name)
        var fcmTokens: [String] = []
        var errors: [Error] = []
        let dispatchGroup = DispatchGroup()
        
        for phone in phoneNumbers {
            dispatchGroup.enter()
            usersRef.child(phone).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(), let userData = snapshot.value as? [String: Any], let fcmToken = userData["fcmtoken"] as? String {
                    fcmTokens.append(fcmToken)
                } else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User or FCM Token not found for phone: \(phone)"])
                    errors.append(error)
                }
                dispatchGroup.leave()
            } withCancel: { error in
                errors.append(error)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !fcmTokens.isEmpty {
                print("✅ Successfully fetched \(fcmTokens.count) FCM tokens.")
                completion(.success(fcmTokens))
            } else if let firstError = errors.first {
                print("❌ Failed to fetch any FCM tokens.")
                completion(.failure(firstError))
            } else {
                let error = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred."])
                completion(.failure(error))
            }
        }
    }
    
    //MARK: Example
    /*
     fetchUsersFCMTokens(phoneNumbers: phoneNumbers) { result in
         switch result {
         case .success(let fcmTokens):
             print("Fetched FCM Tokens: \(fcmTokens)")
         case .failure(let error):
             print("Error fetching FCM Tokens: \(error.localizedDescription)")
         }
     }
     */
    
    //MARK: - Create circle
    func createCircle(name: String, completion: @escaping (Bool, String, [String: Any]?) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            completion(false, "User is not authenticated.", [:])
            return
        }
        
        let code = UUID().uuidString.prefix(6)
        
        let circleData: [String: Any] = [
            FirebaseKeys.code: String(code),
            FirebaseKeys.name: name,
            FirebaseKeys.ownerPhone: DefaultManager.User.PHONE,
            FirebaseKeys.timestamp: Date().getCurrentUTCTimestampInfo().timestampSeconds,
            FirebaseKeys.members: [
                DefaultManager.User.PHONE: [
                    FirebaseKeys.phone: DefaultManager.User.PHONE
                ]
            ]
        ]
        
        ref.child(FirebaseTableName.circle.name).childByAutoId().setValue(circleData) { error, data in
            if let error = error {
                completion(false, error.localizedDescription, nil)
            } else {
                completion(true, "Circle created successfully.", circleData)
            }
        }
    }
    
    //MARK: - Join circle
    func joinCircle(inviteCode: String, completion: @escaping (Bool, String) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            completion(false, "User is not authenticated.")
            return
        }
        
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        // Find circle with invite code
        circlesRef.queryOrdered(byChild: FirebaseKeys.code).queryEqual(toValue: inviteCode)
            .observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(false, "Invalid circle code.")
                    return
                }
                
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot {
                        let circleId = snap.key
                        let membersRef = circlesRef.child(circleId).child(FirebaseKeys.members)
                        
                        // Add new member using phone number as key
                        let newMemberData: [String: Any] = [
                            FirebaseKeys.countryCode: DefaultManager.User.COUNTRY_CODE,
                            FirebaseKeys.phone: DefaultManager.User.PHONE
                        ]
                        
                        membersRef.child(DefaultManager.User.PHONE).setValue(newMemberData) { error, _ in
                            if let error = error {
                                completion(false, error.localizedDescription)
                            } else {
                                completion(true, "Joined circle successfully.")
                            }
                        }
                    }
                }
            }
    }
    
    func joinChildCircle(inviteCode: String, completion: @escaping (Bool, String) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            completion(false, "User is not authenticated.")
            return
        }
        
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        // Find circle with invite code
        circlesRef.queryOrdered(byChild: FirebaseKeys.code).queryEqual(toValue: inviteCode)
            .observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(false, "Invalid circle code.")
                    return
                }
                
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot {
                        let circleId = snap.key
                        let membersRef = circlesRef.child(circleId).child(FirebaseKeys.childNumber)
                        
                        // Add new member using phone number as key
                        let newMemberData: [String: Any] = [
                            FirebaseKeys.phone: DefaultManager.User.PHONE
                        ]
                        
                        membersRef.child(DefaultManager.User.PHONE).setValue(newMemberData) { error, _ in
                            if let error = error {
                                completion(false, error.localizedDescription)
                            } else {
                                completion(true, "Joined circle successfully.")
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Fetch My Circles (Where User Is a Member)
    func getMyCircle(completion: @escaping (Bool, String, [CircleInfo]) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            completion(false, "User is not authenticated.", [])
            return
        }
        
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        circlesRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let allCircles = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(false, "No circles available.", [])
                return
            }
            
            var circles: [CircleInfo] = []
            
            for circle in allCircles {
                if let circleData = circle.value as? [String: Any],
                   let members = circleData[FirebaseKeys.members] as? [String: Any],
                   members[DefaultManager.User.PHONE] != nil {
                    let circleModel = CircleInfo(dictionary: circleData)
                    circles.append(circleModel)
                }
            }
            
            if circles.isEmpty {
                completion(false, "You are not a member of any circle.", [])
            } else {
                completion(true, "Circles fetched successfully.", circles)
            }
        }
    }
    
    // MARK: - FCM Token Update
    func updateFCMToken(){
        if !DefaultManager.User.FCM_TOKEN.isEmpty {
            // ✅ Step 1: Check Authentication
            guard let _ = Auth.auth().currentUser else {
                goToOnboarding()
                return
            }
            
            let userRef = ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)
            // Update FCM token in user's profile
            userRef.updateChildValues([FirebaseKeys.fcmtoken: DefaultManager.User.FCM_TOKEN]) { error, _ in
                if let error = error {
                    print("Failed to update user FCM token: \(error.localizedDescription)")
                } else {
                    print("User FCM token updated successfully.")
                }
            }
        }
    }
    
    // MARK: - Battery Level Update
    func updateBatteryLevel(batteryLevel: Int) {
        if DefaultManager.Permission.BATTERY {
            // ✅ Step 1: Check Authentication
            guard let _ = Auth.auth().currentUser else {
                return
            }
            
            let userRef = ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)
            
            let param = [
                FirebaseKeys.batteryLevel: batteryLevel,
                FirebaseKeys.timestamp: Date().getCurrentUTCTimestampInfo().timestampSeconds
            ] as [String : Any]
            
            // Update battery level in user's profile
            userRef.updateChildValues(param) { error, _ in
                if let error = error {
                    print("Failed to update battery level: \(error.localizedDescription)")
                } else {
                    print("User battery level updated successfully.")
                }
            }
        }
    }
    
    // MARK: - Location Update
    func updateUserLocation(latitude: Double, longitude: Double) {
        if DefaultManager.Permission.LOCATION {
            // ✅ Step 1: Check Authentication
            guard let _ = Auth.auth().currentUser else {
                goToOnboarding()
                return
            }
            
            let userRef = ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)
            
            LocationManager.shared.getAddressFrom(latitude: latitude, longitude: longitude) { address in
                let param: [String: Any] = [
                    FirebaseKeys.address: address ?? "",
                    FirebaseKeys.latitude: latitude,
                    FirebaseKeys.longitude: longitude,
                    FirebaseKeys.timestamp: Date().getCurrentUTCTimestampInfo().timestampSeconds
                ]
                
                userRef.updateChildValues(param) { error, _ in
                    if let error = error {
                        print("Failed to update location: \(error.localizedDescription)")
                    } else {
                        print("User location updated successfully.")
                    }
                }
            }
        }
    }
    
    // MARK: - User Location History Update
    func saveUserLocationHistory(latitude: Double, longitude: Double) {
        // Update current location in user's profile
        updateUserLocation(latitude: latitude, longitude: longitude)
        
        if DefaultManager.Permission.LOCATION {
            // ✅ Step 1: Check Authentication
            guard let _ = Auth.auth().currentUser else {
                goToOnboarding()
                return
            }
            
            let userRef = ref.child(FirebaseTableName.locations.name).child(DefaultManager.User.PHONE)
            let timestamp = Date().getCurrentUTCTimestampInfo().timestampSeconds
            
            let locationData: [String: Any] = [
                FirebaseKeys.latitude: latitude,
                FirebaseKeys.longitude: longitude,
                FirebaseKeys.timestamp: timestamp
            ]
            
            userRef.child("\(timestamp)").setValue(locationData) { error, _ in
                if let error = error {
                    print("❌ Failed to save location: \(error.localizedDescription)")
                } else {
                    print("✅ Added location entry for \(DefaultManager.User.PHONE) at \(timestamp)")
                }
            }
        }
    }
    
    // MARK: - User Profile Update
    func updateUserProfilePicture() {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            return
        }
        
        let userRef = ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)
        
        let param: [String: Any] = [
            FirebaseKeys.profilePicture: DefaultManager.User.PROFILE_PIC,
            FirebaseKeys.timestamp: Date().getCurrentUTCTimestampInfo().timestampSeconds
        ]
        
        userRef.updateChildValues(param) { error, _ in
            if let error = error {
                print("❌ Failed to update profile picture: \(error.localizedDescription)")
            } else {
                print("✅ User profile picture updated successfully.")
            }
        }
    }
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated."])
            completion(.failure(error))
            return
        }
        
        guard let compressedData = image.jpegData(compressionQuality: 0.5),
              let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        
        storageRef.putData(compressedData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                }
            }
        }
    }
    
    // MARK: - Delete User Account and Related Data
    func deleteUserAccountAndData(completion: @escaping (Bool) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            completion(false)
            return
        }
        
        let userRef = ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)
        let circleRef = ref.child(FirebaseTableName.circle.name)
        let locationRef = ref.child(FirebaseTableName.locations.name).child(DefaultManager.User.PHONE)
        
        // Delete circles where user is admin
        func deleteOwnedCircles(completion: @escaping (Bool) -> Void) {
            circleRef.queryOrdered(byChild: FirebaseKeys.ownerPhone).queryEqual(toValue: DefaultManager.User.PHONE).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(true)
                    return
                }
                
                var pending = 0
                var encounteredError = false
                
                for snap in snapshot.children.allObjects as! [DataSnapshot] {
                    pending += 1
                    circleRef.child(snap.key).removeValue { error, _ in
                        if let error = error {
                            print("❌ Error deleting circle: \(error.localizedDescription)")
                            encounteredError = true
                        }
                        pending -= 1
                        if pending == 0 {
                            completion(!encounteredError)
                        }
                    }
                }
            }
        }
        
        // Remove user from other circles as member
        func leaveJoinedCircles(completion: @escaping (Bool) -> Void) {
            circleRef.observeSingleEvent(of: .value) { snapshot in
                var pending = 0
                var encounteredError = false
                
                for circleSnap in snapshot.children.allObjects as! [DataSnapshot] {
                    if circleSnap.childSnapshot(forPath: FirebaseKeys.members).hasChild(DefaultManager.User.PHONE) {
                        pending += 1
                        circleRef.child(circleSnap.key).child(FirebaseKeys.members).child(DefaultManager.User.PHONE).removeValue { error, _ in
                            if let error = error {
                                print("❌ Error removing member: \(error.localizedDescription)")
                                encounteredError = true
                            }
                            pending -= 1
                            if pending == 0 {
                                completion(!encounteredError)
                            }
                        }
                    }
                }
                
                if pending == 0 {
                    completion(!encounteredError)
                }
            }
        }
        
        // Delete location history
        func deleteLocationHistory() {
            locationRef.removeValue { error, _ in
                if let error = error {
                    print("❌ Failed to delete location data: \(error.localizedDescription)")
                } else {
                    print("✅ Location history deleted successfully")
                }
            }
        }
        
        // Delete user data
        func deleteUserProfile() {
            userRef.removeValue { error, _ in
                if let error = error {
                    print("❌ Failed to delete user profile: \(error.localizedDescription)")
                } else {
                    print("✅ User profile deleted successfully")
                }
            }
        }
        
        // Full deletion process
        deleteOwnedCircles { success in
            guard success else {
                completion(false)
                return
            }
            leaveJoinedCircles { success in
                guard success else {
                    completion(false)
                    return
                }
                
                deleteLocationHistory()
                deleteUserProfile()
                completion(true)
            }
        }
    }
    
    //MARK:   Example:
    /*
     deleteUserAccountAndData { success in
         if success {
             // Account deleted successfully
                try? Auth.auth().signOut()
         } else {
             // Show error
         }
     }
     */
    
    // MARK: - Fetch Today's Locations for User

    func fetchTodayUserLocations(for userNumber: String, completion: @escaping ([UserLocationModel]) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            completion([])
            return
        }
        
        // Step 1: Define today's local start and end time
        let calendar = Calendar.current
        let now = Date()
        
        let localStart = calendar.startOfDay(for: now)
        let localEnd = calendar.date(byAdding: .day, value: 1, to: localStart)?.addingTimeInterval(-1) ?? now
        
        // Step 2: Firebase reference
        let ref = Database.database().reference()
        let userRef = ref.child(FirebaseTableName.locations.name).child(userNumber)
        
        userRef.observeSingleEvent(of: .value) { snapshot  in
            guard let data = snapshot.value as? [String: [String: Any]] else {
                print("❌ No data found for user \(userNumber)")
                completion([])
                return
            }
            
            // Step 3: Filter today's locations
            let todayModels: [UserLocationModel] = data.compactMap { (_, value) in
                guard let timestamp = value[FirebaseKeys.timestamp] as? Int else { return nil }
                
                let utcDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
                guard utcDate >= localStart && utcDate <= localEnd else { return nil }
                
                return UserLocationModel(from: value)
            }
            
            completion(todayModels)
        }
    }
    
    // MARK: - Fetch child mode supported group
    func getJoinedCircle(completion: @escaping (Bool, String, [CircleInfo]) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            completion(false, "User is not authenticated.", [])
            return
        }
        
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        circlesRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let allCircles = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(false, "No circles available.", [])
                return
            }
            
            var circles: [CircleInfo] = []
            
            for circle in allCircles {
                if let circleData = circle.value as? [String: Any],
                   let members = circleData[FirebaseKeys.members] as? [String: Any],
                   members[DefaultManager.User.PHONE] != nil && circleData[FirebaseKeys.ownerPhone] as? String != DefaultManager.User.PHONE {
                    let circleModel = CircleInfo(dictionary: circleData)
                    circles.append(circleModel)
                }
            }
            
            if circles.isEmpty {
                completion(false, "You are not a member of any circle.", [])
            } else {
                completion(true, "Circles fetched successfully.", circles)
            }
        }
    }
    
    // MARK: - Fetch child Active Circle
    func getChildActiveCircle(completion: @escaping (Bool, String, [ChildModeCircleInfo]) -> Void) {
        guard let _ = Auth.auth().currentUser else {
            goToOnboarding()
            completion(false, "User is not authenticated.", [])
            return
        }
        
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        circlesRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let allCircles = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(false, "No circles available.", [])
                return
            }
            
            var circles: [ChildModeCircleInfo] = []
            let dispatchGroup = DispatchGroup()
            
            for circle in allCircles {
                if let circleData = circle.value as? [String: Any],
                   let members = circleData[FirebaseKeys.childNumber] as? [String: Any],
                   circleData[FirebaseKeys.ownerPhone] as? String == DefaultManager.User.PHONE {
                    
                    for (_, value) in members {
                        if let memberInfo = value as? [String: Any],
                           let phone = memberInfo["phone"] as? String {
                            
                            dispatchGroup.enter()
                            self.fetchUserData(phoneNumber: phone) { result in
                                switch result {
                                case .success(let userData):
                                    let circleInfo = CircleInfo(dictionary: circleData)
                                    let info = ChildModeCircleInfo()
                                    
                                    info.code = circleInfo.code
                                    info.ownerPhone = circleInfo.ownerPhone
                                    info.circleName = circleInfo.name
                                    info.member = circleInfo.members.count
                                    
                                    info.childPhone = phone
                                    info.childName = userData.name
                                    info.childProfile = userData.profilePic
                                    
                                    circles.append(info)
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                }
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if circles.isEmpty {
                    completion(false, "You are not a member of any circle.", [])
                } else {
                    completion(true, "Circles fetched successfully.", circles)
                }
            }
        }
    }
    
    // MARK: - Disable Child Mode & Remove from Circle
    /// This function disables child mode for a specific child and removes them from the circle.
    /// - Parameters:
    ///   - code: The circle code.
    ///   - childPhone: The child’s phone number.
    ///   - completion: Completion handler with success status and message.
    func disableChildModeAndRemoveChild(fromCircleCode code: String, childPhone: String, completion: @escaping (Bool, String) -> Void) {
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        circlesRef
            .queryOrdered(byChild: FirebaseKeys.code)
            .queryEqual(toValue: code)
            .observeSingleEvent(of: .value) { snapshot in
                
            guard snapshot.exists(), let circles = snapshot.value as? [String: Any] else {
                completion(false, "❌ Circle not found for code: \(code)")
                return
            }
            
            for (circleId, _) in circles {
                let childRef = circlesRef.child(circleId).child(FirebaseKeys.childNumber).child(childPhone)
                childRef.removeValue { error, _ in
                    if let error = error {
                        completion(false, "❌ Failed to remove child from circle: \(error.localizedDescription)")
                    } else {
                        let userRef = self.ref.child(FirebaseTableName.users.name)
                        userRef.child(childPhone).child(FirebaseKeys.childMode).removeValue { error, _ in
                            if let error = error {
                                completion(false, "❌ Failed to delete child_mode: \(error.localizedDescription)")
                            } else {
                                completion(true, "✅ Child removed from circle and child mode disabled.")
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: ------------------------------------------------------------------------------------------------------------------------------------
    
    // Create a circle with a unique invitation code
//    func createCircle(name: String,userName:String, countryCode: String ,userPhone: String, batteryLevel: Int, completion: @escaping (String?) -> Void) {
//        let code = UUID().uuidString.prefix(6) // Short code
//        
//        LocationManager.shared.fetchCurrentLocation { location in
//            
//            let circleData: [String: Any] = [
//                "code": String(code),
//                "name": name,
//                "admin": userPhone,
//                "adminName": userName,
//                "members": [
//                    userPhone: [
//                        "username": "Me",
//                        "country_code": countryCode,
//                        "userPhone": userPhone,
//                        "batteryLevel": batteryLevel,
//                        "latitude": location.coordinate.latitude,
//                        "longitude": location.coordinate.longitude
//                    ]
//                ]
//            ]
//            
//            self.ref.child("circles").childByAutoId().setValue(circleData) { error, _ in
//                if let error = error {
//                    print("Error creating circle: \(error.localizedDescription)")
//                    completion(nil)
//                } else {
//                    print("Circle created successfully with code: \(code)")
//                    completion(String(code)) // Return the generated code
//                }
//            }
//        }
//    }
    
//    func saveFcmTokenFirebase(){
//        if !DefaultManager.User.FCM_TOKEN.isEmpty {
//            ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: DefaultManager.User.PHONE).observeSingleEvent(of: .value) { snapshot in
//                if snapshot.exists() {
//                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
//                        self.ref.child("circles").child(snap.key).updateChildValues(["fcmtoken": DefaultManager.User.FCM_TOKEN])
//                    }
//                }
//            }
//        }
//    }
    
    // Join a circle using the invitation code
//    func joinCircle(withCode code: String,circleId:String,batteryLevel: Int, completion: @escaping (Bool) -> Void) {
//        ref.child("circles").queryOrdered(byChild: "code").queryEqual(toValue: code).observeSingleEvent(of: .value) { snapshot in
//            if snapshot.exists(), let circleSnapshot = snapshot.children.allObjects.first as? DataSnapshot {
//                
//                let friendNumber = circleSnapshot.childSnapshot(forPath: "admin").value as? String ?? ""
//                let frinedName = circleSnapshot.childSnapshot(forPath: "adminName").value as? String ?? ""
//                let friendLat = circleSnapshot.childSnapshot(forPath: "members").childSnapshot(forPath: friendNumber).childSnapshot(forPath: "latitude").value as? Double ?? 0
//                let friendLong = circleSnapshot.childSnapshot(forPath: "members").childSnapshot(forPath: friendNumber).childSnapshot(forPath: "longitude").value as? Double ?? 0
//                
//                print("circleId ==>\(circleId)")
//                print("friendNumber ==>\(friendNumber)")
//                print("frinedName ==>\(frinedName)")
//                print("friendLat ==>\(friendLat)")
//                print("friendLong ==>\(friendLong)")
//                print("circleSnapshot ==>\(circleSnapshot)")
//                
//                
//                self.ref.child("circles").queryOrdered(byChild: "code").queryEqual(toValue: circleId).observeSingleEvent(of: .value) { snapshot in
//                    if snapshot.exists(), let userCircleSnapshot = snapshot.children.allObjects.first as? DataSnapshot {
//                        
//                        
//                        let myNumber = userCircleSnapshot.childSnapshot(forPath: "admin").value as? String ?? ""
//                        let myName = userCircleSnapshot.childSnapshot(forPath: "adminName").value as? String ?? ""
//                        let myLat = userCircleSnapshot.childSnapshot(forPath: "members").childSnapshot(forPath: myNumber).childSnapshot(forPath: "latitude").value as? Double ?? 0
//                        let myLong = userCircleSnapshot.childSnapshot(forPath: "members").childSnapshot(forPath: myNumber).childSnapshot(forPath: "longitude").value as? Double ?? 0
//                        
//                        
//                        // Set Friend Data
//                        
//                        self.ref.child("circles").child(userCircleSnapshot.key).child("members").child(friendNumber).setValue([
//                            "username": frinedName,
//                            "userPhone": friendNumber,
//                            "batteryLevel": batteryLevel,
//                            "latitude": friendLat,
//                            "longitude": friendLong
//                        ]) { error, _ in
//                            if let error = error {
//                                print("Error joining circle: \(error.localizedDescription)")
//                                completion(false)
//                            } else {
//                                print("Joined circle successfully!")
//                                completion(true)
//                            }
//                        }
//                        
//                        // Set Own data from friend List
//                        
//                        self.ref.child("circles").child(circleSnapshot.key).child("members").child(myNumber).setValue([
//                            "username": myName,
//                            "userPhone": myNumber,
//                            "batteryLevel": batteryLevel,
//                            "latitude": myLat,
//                            "longitude": myLong
//                        ]) { error, _ in
//                            if let error = error {
//                                print("Error joining circle: \(error.localizedDescription)")
//                                completion(false)
//                            } else {
//                                print("Joined circle successfully!")
//                                completion(true)
//                            }
//                        }
//                    }
//                }
//            }
//            else {
//                print("Circle with this code does not exist.")
//                completion(false)
//            }
//        }
//    }
    
//    func fetchAllCircles(phoneNumber: String, completion: @escaping ([DataSnapshot]) -> Void) {
//        ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: phoneNumber).observe(.value, with: { snapshot in
//            if snapshot.exists(), let circleSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                completion(circleSnapshot)
//            }else{
//                completion([])
//            }
//        })
//    }
    
    
    //    func fetchCirclesForMember(completion: @escaping ([DataSnapshot]) -> Void) {
    //
    //
    ////        ref.child("circles").child().child("members").observeSingleEvent(of: .value) { snapSort in
    ////
    ////            print(snapSort.key)
    ////        }
    //
    ////        ref.child("circles").observeSingleEvent(of: .value) { snapshot in
    ////            var userCircles:[DataSnapshot] = []
    ////
    ////            for case let circleSnapshot as DataSnapshot in snapshot.children {
    ////                if let circleData = circleSnapshot.value as? [String: Any],
    ////                   let members = circleData["members"] as? [String: Any] {
    ////
    ////                    // Check if the user's phone number is in the members list
    ////                    if members.keys.contains(phoneNumber) {
    ////                        userCircles.append(circleData)
    ////                    }
    ////                }
    ////            }
    ////
    ////            if !userCircles.isEmpty {
    ////                completion(userCircles)
    ////            }
    ////            else {
    ////                print("No circles found for the given phone number.")
    ////                completion([],"")
    ////            }
    ////        }
    //    }
    
//    func fetchMemberDetailsFromID(ID: String, completion: @escaping (String,Int) -> Void){
//        ref.child("circles").child(ID).child("members").observeSingleEvent(of: .value) { snapshot in
//            guard let members = snapshot.value as? [String: Any] else {
//                print("No members found.")
//                completion("",0)
//                return
//            }
//            
//            for (phone, details) in members {
//                if let details = details as? [String: Any],
//                   let batteryLevel = details["batteryLevel"] as? Int {
//                    completion(phone,batteryLevel)
//                    print("Phone: \(phone), Battery Level: \(batteryLevel)%")
//                }
//            }
//        }
//    }
    
    // Update battery level
//    func updateBatteryLevel(userPhone: String, batteryLevel: Int) {
//        ref.child("circles").observeSingleEvent(of: .value) { snapshot in
//            
//            for case let circleSnapshot as DataSnapshot in snapshot.children {
//                if let circleData = circleSnapshot.value as? [String: Any],
//                   let members = circleData["members"] as? [String: Any] {
//                    
//                    // Check if the user's phone number is in the members list
//                    if members.keys.contains(userPhone) && DefaultManager.Permission.BATTERY {
//                        self.ref.child("circles").child(circleSnapshot.key).child("members").child(userPhone).child("batteryLevel").setValue(batteryLevel)
//                    }
//                }
//            }
//        }
//    }
    
//    private func updateLocationInFirebase(latitude: Double, longitude: Double,userPhonenumber:String) {
//        ref.child("circles").observeSingleEvent(of: .value) { snapshot in
//            
//            for case let circleSnapshot as DataSnapshot in snapshot.children {
//                if let circleData = circleSnapshot.value as? [String: Any],
//                   let members = circleData["members"] as? [String: Any] {
//                    
//                    // Check if the user's phone number is in the members list
//                    if members.keys.contains(userPhonenumber) && DefaultManager.Permission.LOCATION {
//                        self.ref.child("circles").child(circleSnapshot.key).child("members").child(userPhonenumber).updateChildValues(["latitude": latitude, "longitude": longitude])
//                    }
//                }
//            }
//        }
//    }
    
//    func updateUserwiseLocationInFirebase(latitude: Double, longitude: Double,userPhonenumber:String) {
//        updateLocationInFirebase(latitude: latitude, longitude: longitude, userPhonenumber: userPhonenumber)
//        if DefaultManager.Permission.LOCATION {
//            let userRef = self.ref.child(FirebaseTableName.locations.name).child(userPhonenumber)
//            let timestamp = Date().getCurrentUTCTimestampInfo().timestampSeconds
//            
//            let locationData: [String: Any] = [
//                "latitude": latitude,
//                "longitude": longitude,
//                "timestamp": timestamp
//            ]
//            
//            userRef.child("\(timestamp)").setValue(locationData) { error, _ in
//                if let error = error {
//                    print("❌ Failed to save location: \(error.localizedDescription)")
//                } else {
//                    print("✅ Added location entry for \(userPhonenumber) at \(timestamp)")
//                }
//            }
//        }
//    }
    
//    func updateUserNameInFirebase(userPhonenumber: String, entername: String, completion: @escaping (Bool, String?) -> Void) {
//        let ref = self.ref.child("circles")
//        let group = DispatchGroup()
//        var updateSuccess = true
//        var errorMessage: String?
//        
//        // Query circles where the user is the admin
//        ref.queryOrdered(byChild: "admin").queryEqual(toValue: userPhonenumber).observeSingleEvent(of: .value) { snapshot in
//            if snapshot.exists() {
//                for snap in snapshot.children.allObjects as! [DataSnapshot] {
//                    group.enter() // Enter the group for the admin update
//                    ref.child(snap.key).updateChildValues(["adminName": entername]) { error, _ in
//                        if let error = error {
//                            updateSuccess = false
//                            errorMessage = "Failed to update adminName: \(error.localizedDescription)"
//                            print(errorMessage ?? "")
//                        }
//                        group.leave() // Leave the group after update
//                    }
//                }
//            }
//            
//            // Query all circles to update members
//            ref.observeSingleEvent(of: .value) { allCirclesSnapshot in
//                for circleSnap in allCirclesSnapshot.children.allObjects as! [DataSnapshot] {
//                    if circleSnap.childSnapshot(forPath: "members").hasChild(userPhonenumber) {
//                        group.enter() // Enter the group for the member update
//                        ref.child(circleSnap.key).child("members").child(userPhonenumber).updateChildValues(["username": entername]) { error, _ in
//                            if let error = error {
//                                updateSuccess = false
//                                errorMessage = "Failed to update username: \(error.localizedDescription)"
//                                print(errorMessage ?? "")
//                            }
//                            group.leave() // Leave the group after update
//                        }
//                    }
//                }
//            }
//        }
//        
//        // Notify when all async updates are complete
//        group.notify(queue: .main) {
//            if updateSuccess {
//                print("All updates are complete.")
//                completion(true, nil) // Success
//            } else {
//                completion(false, errorMessage) // Failure with error
//            }
//        }
//    }
    
//    func isExistingUser(_ phoneNumber: String, completion: @escaping (Bool, [String: Any]?) -> Void) {
//        ref.child("circles")
//            .queryOrdered(byChild: "admin")
//            .queryEqual(toValue: phoneNumber)
//            .observeSingleEvent(of: .value) { snapshot in
//                
//                guard
//                    let data = snapshot.value as? [String: Any],
//                    let firstCircle = data.first,
//                    let circleDict = firstCircle.value as? [String: Any]
//                else {
//                    completion(false, nil) // No user found
//                    return
//                }
//                
//                completion(true, circleDict) // User found
//            }
//    }
    
//    func deleteUserAccount(userPhoneNumber: String, completion: @escaping (Bool) -> Void) {
//        self.ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: userPhoneNumber).observeSingleEvent(of: .value) { snapshot in
//            guard snapshot.exists() else {
//                completion(false) // No circles found for the user
//                return
//            }
//            
//            var pendingOperations = 0 // Tracks the number of pending operations
//            var encounteredError = false // Tracks if an error occurred
//            
//            // Delete circles where the user is the admin
//            for snap in snapshot.children.allObjects as! [DataSnapshot] {
//                pendingOperations += 1 // Increment the counter for each circle deletion
//                
//                self.ref.child("circles").child(snap.key).removeValue { error, _ in
//                    if let error = error {
//                        print("Error deleting circle: \(error.localizedDescription)")
//                        encounteredError = true
//                    }
//                    pendingOperations -= 1 // Decrement the counter
//                    if pendingOperations == 0 {
//                        completion(!encounteredError)
//                    }
//                }
//            }
//            
//            // Delete user from "members" section in all circles
//            self.ref.child("circles").observeSingleEvent(of: .value) { allCirclesSnapshot in
//                for circleSnap in allCirclesSnapshot.children.allObjects as! [DataSnapshot] {
//                    if circleSnap.childSnapshot(forPath: "members").hasChild(userPhoneNumber) {
//                        pendingOperations += 1 // Increment the counter for each member removal
//                        
//                        self.ref.child("circles").child(circleSnap.key).child("members").child(userPhoneNumber).removeValue { error, _ in
//                            if let error = error {
//                                print("Error removing member: \(error.localizedDescription)")
//                                encounteredError = true
//                            }
//                            pendingOperations -= 1 // Decrement the counter
//                            if pendingOperations == 0 {
//                                completion(!encounteredError)
//                            }
//                        }
//                    }
//                }
//                
//                // If no member deletions are pending, ensure completion is called
//                if pendingOperations == 0 {
//                    completion(!encounteredError)
//                }
//            }
//        }
//    }
    
//    func generateAccessToken(completion: @escaping (String?) -> Void) {
//        // Path to your Service Account JSON file
//        guard let filePath = Bundle.main.path(forResource: "phonetracker", ofType: "json"),
//              let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
//              let serviceAccount = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//              let clientEmail = serviceAccount["client_email"] as? String,
//              let privateKey = serviceAccount["private_key"] as? String else {
//            print("Error: Unable to load service account JSON.")
//            completion(nil)
//            return
//        }
//        
//        let currentTime = Date().getCurrentUTCTimestampInfo().timestampSeconds
//        let expirationTime = currentTime + 3600 // Token valid for 1 hour
//        
//        // Create JWT claims
//        let claims = GoogleJWTClaims(
//            iss: clientEmail,
//            scope: "https://www.googleapis.com/auth/firebase.messaging",
//            aud: "https://oauth2.googleapis.com/token",
//            exp: expirationTime,
//            iat: currentTime
//        )
//        
//        // Create JWT signer
//        var jwt = JWT(claims: claims)
//        guard let privateKeyData = privateKey.data(using: .utf8) else {
//            print("Error: Unable to convert private key to Data.")
//            completion(nil)
//            return
//        }
//        
//        let jwtSigner = JWTSigner.rs256(privateKey: privateKeyData)
//        
//        // Encode JWT
//        guard let jwtString = try? jwt.sign(using: jwtSigner) else {
//            print("Error: Unable to sign JWT.")
//            completion(nil)
//            return
//        }
//        
//        // Request Access Token
//        let url = URL(string: "https://oauth2.googleapis.com/token")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        let bodyString = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwtString)"
//        request.httpBody = bodyString.data(using: .utf8)
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil,
//                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                  let accessToken = json["access_token"] as? String else {
//                print("Error: Unable to fetch access token.")
//                completion(nil)
//                return
//            }
//            
//            completion(accessToken)
//        }
//        task.resume()
//    }
    
//    func sendPushNotification(type: NotificationType, fcmToken: String, title: String = APP_NAME, body: String, code: String? = nil) {
//        generateAccessToken { accessToken in
//            guard let accessToken = accessToken else {
//                print("Error: Unable to generate access token.")
//                return
//            }
//            
//            let url = URL(string: "https://fcm.googleapis.com/v1/projects/ios---phone-tracker/messages:send")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//            
//            var message: [String: Any] = [:]
//            if type == .sos {
//                message = [
//                    "message": [
//                        "token": fcmToken,
//                        "notification": [
//                            "title": title,
//                            "body": body
//                        ],
//                        "data": [
//                            "type": type.rawValue
//                        ]
//                    ]
//                ]
//            } else if type == .disableChildMode {
//                message = [
//                    "message": [
//                        "token": fcmToken,
//                        "notification": [
//                            "title": title,
//                            "body": body
//                        ],
//                        "data": [
//                            "code": code ?? "N/A",
//                            "type": type.rawValue
//                        ]
//                    ]
//                ]
//            }
//            
//            guard let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []) else {
//                print("Error: Unable to serialize JSON.")
//                return
//            }
//            
//            request.httpBody = jsonData
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("Error sending notification: \(error)")
//                    return
//                }
//                
//                if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                    print("Notification sent successfully: \(responseString)")
//                }
//            }
//            task.resume()
//        }
//    }
    
    //    func fetchTodayLocations(for userNumber: String, completion: @escaping ([UserLocationModel]) -> Void) {
    //        let calendar = Calendar.current
    //        let now = Date()
    //
    //        let startOfToday = Calendar.current.startOfDay(for: now)
    //        let endOfToday = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfToday)!
    //
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    //        formatter.timeZone = .current
    //
    //        let formattedStartOfToday = formatter.string(from: startOfToday)
    //        let formattedEndOfToday = formatter.string(from: endOfToday)
    //
    //        let formatter1 = DateFormatter()
    //        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
    //        formatter1.timeZone = .init(secondsFromGMT: 0)
    //
    //        guard let startOfDay = formatter1.date(from: formattedStartOfToday) else {
    //            print("❌ Failed to convert formatted string back to Date.")
    //            return
    //        }
    //
    //        guard let endOfDay = formatter1.date(from: formattedEndOfToday) else {
    //            print("❌ Failed to convert formatted string back to Date.")
    //            return
    //        }
    //
    //        // Convert to UTC timestamps
    //        let startTimestamp = startOfDay.getCurrentUTCTimestampInfo().timestampSeconds
    //        let endTimestamp = endOfDay.getCurrentUTCTimestampInfo().timestampSeconds
    //
    //        // Reference to user's location data
    //        let ref = Database.database().reference()
    //        let userRef = ref.child(FirebaseTableName.locations.name).child(userNumber)
    //
    //        userRef.observeSingleEvent(of: .value) { snapshot in
    //            guard let data = snapshot.value as? [String: [String: Any]] else {
    //                print("❌ No data")
    //                completion([])
    //                return
    //            }
    //
    //            let todayModels: [UserLocationModel] = data.compactMap { (_, value) in
    //                guard let timestamp = value["timestamp"] as? Int,
    //                      timestamp >= startTimestamp,
    //                      timestamp <= endTimestamp else {
    //                    return nil
    //                }
    //                print(value["timestamp"])
    //                return UserLocationModel(from: value)
    //            }
    //
    //            completion(todayModels)
    //        }
    //    }
    
//    func fetchTodayLocations(for userNumber: String, completion: @escaping ([UserLocationModel]) -> Void) {
//        
//        // Step 1: Define local start and end of today
//        let calendar = Calendar.current
//        let now = Date()
//        
//        let localStart = calendar.startOfDay(for: now)
//        let localEnd = calendar.date(byAdding: .day, value: 1, to: localStart)!.addingTimeInterval(-1)
//        
//        // Step 2: Firebase reference
//        let ref = Database.database().reference()
//        let userRef = ref.child(FirebaseTableName.locations.name).child(userNumber)
//        
//        userRef.observeSingleEvent(of: .value) { snapshot in
//            guard let data = snapshot.value as? [String: [String: Any]] else {
//                print("❌ No data")
//                completion([])
//                return
//            }
//            
//            let todayModels: [UserLocationModel] = data.compactMap { (_, value) in
//                guard let timestamp = value["timestamp"] as? Int else {
//                    return nil
//                }
//                
//                // Convert UTC timestamp to Date
//                let utcDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
//                
//                // Check if that date falls within today's local range
//                guard utcDate >= localStart && utcDate <= localEnd else {
//                    return nil
//                }
//                
//                return UserLocationModel(from: value)
//            }
//            
//            completion(todayModels)
//        }
//    }
    
}
