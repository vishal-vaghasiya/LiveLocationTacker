//
//  FirebaseManager.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
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

struct UserLocationModel {
    let latitude: Double
    let longitude: Double
    let timestamp: Int

    init?(from dict: [String: Any]) {
        guard let lat = dict["latitude"] as? Double,
              let lon = dict["longitude"] as? Double,
              let ts = dict["timestamp"] as? Int else {
            return nil
        }
        self.latitude = lat
        self.longitude = lon
        self.timestamp = ts
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
            goToWelcome()
            completion(false, "User is not authenticated.", nil)
            return
        }
        
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
            goToWelcome()
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
                completion(true, "User data updated successfully.")
            }
        }
    }
    
    //MARK: Example:
    /*LocationManager.shared.getCurrentLocation { location in
        LocationManager.shared.getGoogleAddress(lat: location.coordinate.latitude, long: location.coordinate.longitude) { address in
            let param: [String: Any] = [
                "name": "",
                "gender": "male",
                "country_code": "91",
                "phone": "8888888888",
                "profile_pic": "",
                "battery_level": 100,
                "fcmtoken": DefaultManager.User.FCM_TOKEN,
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "address": address ?? "N/A",
                "timestamp": Date().getCurrentUTCTimestampInfo().timestampSeconds
            ]
            FirebaseManager().checkAndSaveUser(phoneNumber: "8888888888", param: param) { success, message, userData  in
                print(message)
                if let user = userData {
                    print("User Data: \(user)")
                }
                
                let updatedData: [String: Any] = [
                    "name": "",
                    "timestamp": Date().getCurrentUTCTimestampInfo().timestampSeconds
                ]
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    FirebaseManager().updateUserData(phoneNumber: "8888888888", updatedValues: updatedData) { success, message in
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
            goToWelcome()
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
            goToWelcome()
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
            goToWelcome()
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
    
    // MARK: - Check if Current User Exists in Any Child Circle
    func isUserInAnyChildCircle() {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
            DefaultManager.User.IS_CHILD_MODE_ENABLE = false
            return
        }

        let circlesRef = ref.child(FirebaseTableName.circle.name)

        // ✅ Step 2: Fetch all circles
        circlesRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(),
                  let allCircles = snapshot.children.allObjects as? [DataSnapshot] else {
                AppData.shared.activeChildCircle = CircleInfo()
                DefaultManager.User.IS_CHILD_MODE_ENABLE = false
                return
            }

            // ✅ Step 3: Loop through all circles and check child_number
            for circle in allCircles {
                if let childNumbers = circle.childSnapshot(forPath: FirebaseKeys.childNumber).value as? [String: Any],
                   childNumbers.keys.contains(DefaultManager.User.PHONE) {
                    guard circle.exists(),
                          let circleData = circle.value as? [String: Any] else {
                        AppData.shared.activeChildCircle = CircleInfo()
                        DefaultManager.User.IS_CHILD_MODE_ENABLE = false
                        return
                    }
                    
                    let circleInfo = CircleInfo(dictionary: circleData)
                    AppData.shared.activeChildCircle = circleInfo
                    DefaultManager.User.IS_CHILD_MODE_ENABLE = true
                    return
                }
            }
            DefaultManager.User.IS_CHILD_MODE_ENABLE = false
            AppData.shared.activeChildCircle = CircleInfo()
        }
    }
    
    // MARK: - Fetch FCM Tokens by Phone Numbers
    func fetchUsersFCMTokens(phoneNumbers: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
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
            goToWelcome()
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
            goToWelcome()
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
    
    //MARK: ADD TO CHILD CIRCLE
    func addToChildCircle(from code: String, childPhone: String, completion: @escaping (Bool, String) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
            completion(false, "User is not authenticated.")
            return
        }
        
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        // Find circle with invite code
        circlesRef.queryOrdered(byChild: FirebaseKeys.code).queryEqual(toValue: code)
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
                            FirebaseKeys.phone: childPhone
                        ]
                        
                        membersRef.child(childPhone).setValue(newMemberData) { error, _ in
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
    
    //MARK: REMOVE TO CHILD CIRCLE
    func removeToChildCircle(from code: String, childPhone: String, completion: @escaping (Bool, String) -> Void) {
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
    
    // MARK: - Fetch Circle Info by Code
    func fetchCircleInfo(code: String, completion: @escaping (Bool, String, CircleInfo?) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
            completion(false, "❌ User is not authenticated.", nil)
            return
        }
        
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        // ✅ Step 2: Find circle with invite code
        circlesRef
            .queryOrdered(byChild: FirebaseKeys.code)
            .queryEqual(toValue: code)
            .observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let allCircles = snapshot.children.allObjects as? [DataSnapshot],
                      let firstCircle = allCircles.first,
                      let circleData = firstCircle.value as? [String: Any] else {
                    completion(false, "⚠️ No circle found for code: \(code)", nil)
                    return
                }
                
                let circleInfo = CircleInfo(dictionary: circleData)
                completion(true, "✅ Circle info fetched successfully.", circleInfo)
            } withCancel: { error in
                completion(false, "❌ Failed to fetch circle info: \(error.localizedDescription)", nil)
            }
    }
    
    //MARK: - Add Member to circle
    func addMemberToCircle(inviteCode: String, countryCode: String, phoneNumber: String, completion: @escaping (Bool, String) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
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
                            FirebaseKeys.countryCode: countryCode,
                            FirebaseKeys.phone: phoneNumber
                        ]
                        
                        membersRef.child(phoneNumber).setValue(newMemberData) { error, _ in
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
    
    //MARK: - Update circle
    func updateCircle(
        code: String,
        name: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
            completion(false, "User is not authenticated.")
            return
        }

        let circlesRef = ref.child(FirebaseTableName.circle.name)

        circlesRef
            .queryOrdered(byChild: FirebaseKeys.code)
            .queryEqual(toValue: code)
            .observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(false, "Invalid circle code.")
                    return
                }

                for child in snapshot.children {
                    if let snap = child as? DataSnapshot {
                        let circleId = snap.key
                        let circleRef = circlesRef.child(circleId)
                        // Only update the circle name
                        circleRef.updateChildValues([FirebaseKeys.name: name]) { error, _ in
                            if let error = error {
                                completion(false, "❌ Failed to update circle name: \(error.localizedDescription)")
                            } else {
                                completion(true, "✅ Circle name updated successfully.")
                            }
                        }
                    }
                }
            }
    }
    
    //MARK: - Remove a single member from circle
    func removeMember(
        code: String,
        phone: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
            completion(false, "User is not authenticated.")
            return
        }
        
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        circlesRef
            .queryOrdered(byChild: FirebaseKeys.code)
            .queryEqual(toValue: code)
            .observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(false, "Invalid circle code.")
                    return
                }
                
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot {
                        let circleId = snap.key
                        let membersRef = circlesRef.child(circleId).child(FirebaseKeys.members)
                        membersRef.child(phone).removeValue { error, _ in
                            if let error = error {
                                completion(false, "❌ Failed to remove member: \(error.localizedDescription)")
                            } else {
                                completion(true, "✅ Member removed successfully.")
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
            goToWelcome()
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
                goToWelcome()
                return
            }
            
            let userRef = ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)
            // Update FCM token in user's profile
            userRef.updateChildValues([FirebaseKeys.fcmtoken: DefaultManager.User.FCM_TOKEN]) { error, _ in
                if let error = error {
                    print("Failed to update user FCM token: \(error.localizedDescription)")
                } /*else {
                    print("User FCM token updated successfully.")
                }*/
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
                } /*else {
                    print("User battery level updated successfully.")
                }*/
            }
        }
    }
    
    // MARK: - Location Update
    func updateUserLocation(latitude: Double, longitude: Double) {
        if DefaultManager.Permission.LOCATION {
            // ✅ Step 1: Check Authentication
            guard let _ = Auth.auth().currentUser else {
                goToWelcome()
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
                    } /*else {
                        print("User location updated successfully.")
                    }*/
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
                goToWelcome()
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
                } /*else {
                    print("✅ Added location entry for \(DefaultManager.User.PHONE) at \(timestamp)")
                }*/
            }
        }
    }
    
    // MARK: - User Profile Update
    func updateUserProfilePicture(for url: String, completion: @escaping (Bool, String) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
            completion(false, "❌ User is not authenticated.")
            return
        }
        
        let userRef = ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)
        
        let param: [String: Any] = [
            FirebaseKeys.profilePicture: url,
            FirebaseKeys.timestamp: Date().getCurrentUTCTimestampInfo().timestampSeconds
        ]
        
        userRef.updateChildValues(param) { error, _ in
            if let error = error {
                let message = "❌ Failed to update profile picture: \(error.localizedDescription)"
                print(message)
                completion(false, message)
            } else {
                let message = "✅ User profile picture updated successfully."
                print(message)
                completion(true, message)
            }
        }
    }
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
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
    
    func deleteUserProfileImage(
        filePath: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        // ✅ Step 1: Get a reference to Firebase Storage
        let storageRef = Storage.storage().reference(forURL: filePath)

        // ✅ Step 2: Delete the file
        storageRef.delete { error in
            if let error = error {
                let message = "❌ Failed to delete profile image: \(error.localizedDescription)"
                print(message)
                completion(false, message)
                return
            }

            print("✅ Profile image deleted from storage")

            // ✅ Step 3: Check Authentication
            guard let _ = Auth.auth().currentUser else {
                goToWelcome()
                completion(false, "❌ User is not authenticated.")
                return
            }

            let userRef = self.ref.child(FirebaseTableName.users.name).child(DefaultManager.User.PHONE)

            let param: [String: Any] = [
                FirebaseKeys.profilePicture: "",
                FirebaseKeys.timestamp: Date().getCurrentUTCTimestampInfo().timestampSeconds
            ]

            userRef.updateChildValues(param) { error, _ in
                if let error = error {
                    let message = "❌ Failed to clear profile picture in database: \(error.localizedDescription)"
                    print(message)
                    completion(false, message)
                } else {
                    let message = "✅ Profile image removed successfully."
                    print(message)
                    completion(true, message)
                }
            }
        }
    }
    
    // MARK: - Delete User Account and Related Data
    func deleteUserAccountAndData(completion: @escaping (Bool) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
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
                } /*else {
                    print("✅ Location history deleted successfully")
                }*/
            }
        }
        
        // Delete user data
        func deleteUserProfile() {
            userRef.removeValue { error, _ in
                if let error = error {
                    print("❌ Failed to delete user profile: \(error.localizedDescription)")
                } /*else {
                    print("✅ User profile deleted successfully")
                }*/
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
            goToWelcome()
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
            goToWelcome()
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
            goToWelcome()
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
                                    info.childName = getFullName(firstName: userData.firstName, lastName: userData.lastName)
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
    
    // MARK: - Fetch Circles Owned by Current User
    func fetchCirclesOwnedByCurrentUser(completion: @escaping (Bool, String, [CircleInfo]) -> Void) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
            completion(false, "❌ User is not authenticated.", [])
            return
        }
        
        let circlesRef = ref.child(FirebaseTableName.circle.name)
        
        // ✅ Step 2: Fetch all circles
        circlesRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(),
                  let allCircles = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(false, "⚠️ No circles found in database.", [])
                return
            }
            
            // ✅ Step 3: Filter circles owned by current user
            var ownedCircles: [CircleInfo] = []
            
            for circle in allCircles {
                if let circleData = circle.value as? [String: Any],
                   circleData[FirebaseKeys.ownerPhone] as? String == DefaultManager.User.PHONE {
                    let circleModel = CircleInfo(dictionary: circleData)
                    ownedCircles.append(circleModel)
                }
            }
            
            // ✅ Step 4: Return results
            if ownedCircles.isEmpty {
                completion(false, "⚠️ You don’t own any circles.", [])
            } else {
                completion(true, "✅ Circles owned by you fetched successfully.", ownedCircles)
            }
        }
    }
    
    // MARK: - Fetch Multiple Users by Phone Numbers
    func fetchUsersByPhoneNumbers(
        phoneNumbers: [String],
        completion: @escaping (Bool, String, [UserInfo]) -> Void
    ) {
        // ✅ Step 1: Check Authentication
        guard let _ = Auth.auth().currentUser else {
            goToWelcome()
            completion(false, "❌ User is not authenticated.", [])
            return
        }
        
        let usersRef = ref.child(FirebaseTableName.users.name)
        var users: [UserInfo] = []
        var errors: [String] = []
        let dispatchGroup = DispatchGroup()
        
        for phone in phoneNumbers {
            dispatchGroup.enter()
            usersRef.child(phone).observeSingleEvent(of: .value) { snapshot in
                if let userData = snapshot.value as? [String: Any] {
                    let user = UserInfo(dictionary: userData)
                    users.append(user)
                } else {
                    errors.append("⚠️ User not found for phone: \(phone)")
                }
                dispatchGroup.leave()
            } withCancel: { error in
                errors.append("❌ Failed to fetch user (\(phone)): \(error.localizedDescription)")
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !users.isEmpty {
                completion(true, "✅ \(users.count) user(s) fetched successfully.", users)
            } else {
                completion(false, errors.first ?? "❌ No users found.", [])
            }
        }
    }
    
}
