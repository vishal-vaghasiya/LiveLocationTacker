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



struct GoogleJWTClaims: Claims {
    let iss: String // Issuer (email from service account)
    let scope: String
    let aud: String
    let exp: Int
    let iat: Int
}


class FirebaseManager {
    
    let ref: DatabaseReference

    init() {
        ref = Database.database().reference()
    }
    
    func sendMobileOTP(phoneNumber: String, completion: @escaping (Bool, String?) -> Void){
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("Error sending OTP: \(error.localizedDescription), \(error)")
                completion(false ,"Error sending OTP: \(error.localizedDescription)")
                return
            }
            
            // Save the verification ID for later use
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            completion(true, "OTP sent successfully")
        }
    }
    
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
    
    // Create a circle with a unique invitation code
    func createCircle(name: String,userName:String,userPhone: String, batteryLevel: Int, completion: @escaping (String?) -> Void) {
        let code = UUID().uuidString.prefix(6) // Short code

        LocationManager.shared.getCurrentLocation { location in
            
            let circleData: [String: Any] = [
                "code": String(code),
                "name": name,
                "admin": userPhone,
                "adminName": userName,
                "members": [
                    userPhone: [
                        "username": "Me",
                        "userPhone": userPhone,
                        "batteryLevel": batteryLevel,
                        "latitude": location.coordinate.latitude,
                        "longitude": location.coordinate.longitude
                    ]
                ]
            ]

            self.ref.child("circles").childByAutoId().setValue(circleData) { error, _ in
                if let error = error {
                    print("Error creating circle: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    print("Circle created successfully with code: \(code)")
                    completion(String(code)) // Return the generated code
                }
            }
        }
    }

    func saveFcmTokenFirebase(){
        if Constants.USERDEFAULTS.getFCMToken().isEmpty == false {
            ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: Constants.USERDEFAULTS.getCurrentuserNumber()).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
                        self.ref.child("circles").child(snap.key).updateChildValues(["fcmtoken": Constants.USERDEFAULTS.getFCMToken()])
                    }
                }
            }
        }
        else{
            print("fcmtoken is empty")
        }
    }
    
    // Join a circle using the invitation code
    func joinCircle(withCode code: String,circleId:String,batteryLevel: Int, completion: @escaping (Bool) -> Void) {
        ref.child("circles").queryOrdered(byChild: "code").queryEqual(toValue: code).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let circleSnapshot = snapshot.children.allObjects.first as? DataSnapshot {
                
                let friendNumber = circleSnapshot.childSnapshot(forPath: "admin").value as? String ?? ""
                let frinedName = circleSnapshot.childSnapshot(forPath: "adminName").value as? String ?? ""
                let friendLat = circleSnapshot.childSnapshot(forPath: "members").childSnapshot(forPath: friendNumber).childSnapshot(forPath: "latitude").value as? Double ?? 0
                let friendLong = circleSnapshot.childSnapshot(forPath: "members").childSnapshot(forPath: friendNumber).childSnapshot(forPath: "longitude").value as? Double ?? 0
                
                print("circleId ==>\(circleId)")
                print("friendNumber ==>\(friendNumber)")
                print("frinedName ==>\(frinedName)")
                print("friendLat ==>\(friendLat)")
                print("friendLong ==>\(friendLong)")
                print("circleSnapshot ==>\(circleSnapshot)")
                
                
                self.ref.child("circles").queryOrdered(byChild: "code").queryEqual(toValue: circleId).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists(), let userCircleSnapshot = snapshot.children.allObjects.first as? DataSnapshot {
                        
                        
                        let myNumber = userCircleSnapshot.childSnapshot(forPath: "admin").value as? String ?? ""
                        let myName = userCircleSnapshot.childSnapshot(forPath: "adminName").value as? String ?? ""
                        let myLat = userCircleSnapshot.childSnapshot(forPath: "members").childSnapshot(forPath: myNumber).childSnapshot(forPath: "latitude").value as? Double ?? 0
                        let myLong = userCircleSnapshot.childSnapshot(forPath: "members").childSnapshot(forPath: myNumber).childSnapshot(forPath: "longitude").value as? Double ?? 0
                        
                        
                        // Set Friend Data
                        
                        self.ref.child("circles").child(userCircleSnapshot.key).child("members").child(friendNumber).setValue([
                            "username": frinedName,
                            "userPhone": friendNumber,
                            "batteryLevel": batteryLevel,
                            "latitude": friendLat,
                            "longitude": friendLong
                        ]) { error, _ in
                            if let error = error {
                                print("Error joining circle: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("Joined circle successfully!")
                                completion(true)
                            }
                        }
                        
                        // Set Own data from friend List
                        
                        self.ref.child("circles").child(circleSnapshot.key).child("members").child(myNumber).setValue([
                            "username": myName,
                            "userPhone": myNumber,
                            "batteryLevel": batteryLevel,
                            "latitude": myLat,
                            "longitude": myLong
                        ]) { error, _ in
                            if let error = error {
                                print("Error joining circle: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("Joined circle successfully!")
                                completion(true)
                            }
                        }
                    }
                }
            }
            else {
                print("Circle with this code does not exist.")
                completion(false)
            }
        }
    }
    
    func fetchAllCircles(phoneNumber: String, completion: @escaping ([DataSnapshot]) -> Void) {
        ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: phoneNumber).observe(.value, with: { snapshot in
            if snapshot.exists(), let circleSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                completion(circleSnapshot)
            }else{
                completion([])
            }
        })
    }
    
    
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

    func fetchMemberDetailsFromID(ID: String, completion: @escaping (String,Int) -> Void){
        ref.child("circles").child(ID).child("members").observeSingleEvent(of: .value) { snapshot in
            guard let members = snapshot.value as? [String: Any] else {
                print("No members found.")
                completion("",0)
                return
            }
            
            for (phone, details) in members {
                if let details = details as? [String: Any],
                   let batteryLevel = details["batteryLevel"] as? Int {
                    completion(phone,batteryLevel)
                    print("Phone: \(phone), Battery Level: \(batteryLevel)%")
                }
            }
        }
    }
    
    // Update battery level
    func updateBatteryLevel(userPhone: String, batteryLevel: Int) {
        ref.child("circles").observeSingleEvent(of: .value) { snapshot in
            
            for case let circleSnapshot as DataSnapshot in snapshot.children {
                if let circleData = circleSnapshot.value as? [String: Any],
                   let members = circleData["members"] as? [String: Any] {
                    
                    // Check if the user's phone number is in the members list
                    if members.keys.contains(userPhone) && Constants.USERDEFAULTS.getBatterySharing() {
                        self.ref.child("circles").child(circleSnapshot.key).child("members").child(userPhone).child("batteryLevel").setValue(batteryLevel)
                    }
                }
            }
        }
    }
    
    private func updateLocationInFirebase(latitude: Double, longitude: Double,userPhonenumber:String) {
        ref.child("circles").observeSingleEvent(of: .value) { snapshot in
            
            for case let circleSnapshot as DataSnapshot in snapshot.children {
                if let circleData = circleSnapshot.value as? [String: Any],
                   let members = circleData["members"] as? [String: Any] {
                    
                    // Check if the user's phone number is in the members list
                    if members.keys.contains(userPhonenumber) && Constants.USERDEFAULTS.getLocationSharing() {
                        self.ref.child("circles").child(circleSnapshot.key).child("members").child(userPhonenumber).updateChildValues(["latitude": latitude, "longitude": longitude])
                    }
                }
            }
        }
    }
    
    func updateUserwiseLocationInFirebase(latitude: Double, longitude: Double,userPhonenumber:String) {
        updateLocationInFirebase(latitude: latitude, longitude: longitude, userPhonenumber: userPhonenumber)
        
        //        ref.child("circles").observeSingleEvent(of: .value) { snapshot in
        
        //            for case let circleSnapshot as DataSnapshot in snapshot.children {
        //                if let circleData = circleSnapshot.value as? [String: Any],
        //                   let members = circleData["members"] as? [String: Any] {
        
        // Check if the user's phone number is in the members list
        if /*members.keys.contains(userPhonenumber) && */Constants.USERDEFAULTS.getLocationSharing() {
            let userRef = self.ref.child("user_locations").child(userPhonenumber)
            let timestamp = Date().getCurrentUTCTimestampInfo().timestampSeconds
            
            let locationData: [String: Any] = [
                "latitude": latitude,
                "longitude": longitude,
                "timestamp": timestamp
            ]
            
            userRef.child("\(timestamp)").setValue(locationData) { error, _ in
                if let error = error {
                    print("❌ Failed to save location: \(error.localizedDescription)")
                } else {
                    print("✅ Added location entry for \(userPhonenumber) at \(timestamp)")
                }
            }
        }
        //                }
        //            }
        //        }
    }
    
    func updateUserNameInFirebase(userPhonenumber: String, entername: String, completion: @escaping (Bool, String?) -> Void) {
        let ref = self.ref.child("circles")
        let group = DispatchGroup()
        var updateSuccess = true
        var errorMessage: String?

        // Query circles where the user is the admin
        ref.queryOrdered(byChild: "admin").queryEqual(toValue: userPhonenumber).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                for snap in snapshot.children.allObjects as! [DataSnapshot] {
                    group.enter() // Enter the group for the admin update
                    ref.child(snap.key).updateChildValues(["adminName": entername]) { error, _ in
                        if let error = error {
                            updateSuccess = false
                            errorMessage = "Failed to update adminName: \(error.localizedDescription)"
                            print(errorMessage ?? "")
                        }
                        group.leave() // Leave the group after update
                    }
                }
            }
            
            // Query all circles to update members
            ref.observeSingleEvent(of: .value) { allCirclesSnapshot in
                for circleSnap in allCirclesSnapshot.children.allObjects as! [DataSnapshot] {
                    if circleSnap.childSnapshot(forPath: "members").hasChild(userPhonenumber) {
                        group.enter() // Enter the group for the member update
                        ref.child(circleSnap.key).child("members").child(userPhonenumber).updateChildValues(["username": entername]) { error, _ in
                            if let error = error {
                                updateSuccess = false
                                errorMessage = "Failed to update username: \(error.localizedDescription)"
                                print(errorMessage ?? "")
                            }
                            group.leave() // Leave the group after update
                        }
                    }
                }
            }
        }
        
        // Notify when all async updates are complete
        group.notify(queue: .main) {
            if updateSuccess {
                print("All updates are complete.")
                completion(true, nil) // Success
            } else {
                completion(false, errorMessage) // Failure with error
            }
        }
    }

    
    func deleteUserAccount(userPhoneNumber: String, completion: @escaping (Bool) -> Void) {
        self.ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: userPhoneNumber).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(false) // No circles found for the user
                return
            }
            
            var pendingOperations = 0 // Tracks the number of pending operations
            var encounteredError = false // Tracks if an error occurred
            
            // Delete circles where the user is the admin
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                pendingOperations += 1 // Increment the counter for each circle deletion
                
                self.ref.child("circles").child(snap.key).removeValue { error, _ in
                    if let error = error {
                        print("Error deleting circle: \(error.localizedDescription)")
                        encounteredError = true
                    }
                    pendingOperations -= 1 // Decrement the counter
                    if pendingOperations == 0 {
                        completion(!encounteredError)
                    }
                }
            }
            
            // Delete user from "members" section in all circles
            self.ref.child("circles").observeSingleEvent(of: .value) { allCirclesSnapshot in
                for circleSnap in allCirclesSnapshot.children.allObjects as! [DataSnapshot] {
                    if circleSnap.childSnapshot(forPath: "members").hasChild(userPhoneNumber) {
                        pendingOperations += 1 // Increment the counter for each member removal
                        
                        self.ref.child("circles").child(circleSnap.key).child("members").child(userPhoneNumber).removeValue { error, _ in
                            if let error = error {
                                print("Error removing member: \(error.localizedDescription)")
                                encounteredError = true
                            }
                            pendingOperations -= 1 // Decrement the counter
                            if pendingOperations == 0 {
                                completion(!encounteredError)
                            }
                        }
                    }
                }
                
                // If no member deletions are pending, ensure completion is called
                if pendingOperations == 0 {
                    completion(!encounteredError)
                }
            }
        }
    }

    func generateAccessToken(completion: @escaping (String?) -> Void) {
        // Path to your Service Account JSON file
        guard let filePath = Bundle.main.path(forResource: "phonetracker", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
              let serviceAccount = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let clientEmail = serviceAccount["client_email"] as? String,
              let privateKey = serviceAccount["private_key"] as? String else {
            print("Error: Unable to load service account JSON.")
            completion(nil)
            return
        }

        let currentTime = Int(Date().timeIntervalSince1970)
        let expirationTime = currentTime + 3600 // Token valid for 1 hour

        // Create JWT claims
        let claims = GoogleJWTClaims(
            iss: clientEmail,
            scope: "https://www.googleapis.com/auth/firebase.messaging",
            aud: "https://oauth2.googleapis.com/token",
            exp: expirationTime,
            iat: currentTime
        )

        // Create JWT signer
        var jwt = JWT(claims: claims)
        guard let privateKeyData = privateKey.data(using: .utf8) else {
            print("Error: Unable to convert private key to Data.")
            completion(nil)
            return
        }

        let jwtSigner = JWTSigner.rs256(privateKey: privateKeyData)
        
        // Encode JWT
        guard let jwtString = try? jwt.sign(using: jwtSigner) else {
            print("Error: Unable to sign JWT.")
            completion(nil)
            return
        }

        // Request Access Token
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwtString)"
        request.httpBody = bodyString.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let accessToken = json["access_token"] as? String else {
                print("Error: Unable to fetch access token.")
                completion(nil)
                return
            }

            completion(accessToken)
        }
        task.resume()
    }

    func sendPushNotification(fcmToken: String, title: String = Constants.APP_NAME, body: String) {
        generateAccessToken { accessToken in
            guard let accessToken = accessToken else {
                print("Error: Unable to generate access token.")
                return
            }
            
            print("aceesToken ==> \(accessToken)")
            
            let url = URL(string: "https://fcm.googleapis.com/v1/projects/phone-tracker-4b3f3/messages:send")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let message: [String: Any] = [
                "message": [
                    "token": fcmToken,
                    "notification": [
                        "title": title,
                        "body": body
                    ]
                ]
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []) else {
                print("Error: Unable to serialize JSON.")
                return
            }

            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending notification: \(error)")
                    return
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Notification sent successfully: \(responseString)")
                }
            }
            task.resume()
        }
    }
    
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
//        let userRef = ref.child("user_locations").child(userNumber)
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
    
    func fetchTodayLocations(for userNumber: String, completion: @escaping ([UserLocationModel]) -> Void) {
        
        // Step 1: Define local start and end of today
        let calendar = Calendar.current
        let now = Date()
        
        let localStart = calendar.startOfDay(for: now)
        let localEnd = calendar.date(byAdding: .day, value: 1, to: localStart)!.addingTimeInterval(-1)

        // Step 2: Firebase reference
        let ref = Database.database().reference()
        let userRef = ref.child("user_locations").child(userNumber)
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: [String: Any]] else {
                print("❌ No data")
                completion([])
                return
            }
            
            let todayModels: [UserLocationModel] = data.compactMap { (_, value) in
                guard let timestamp = value["timestamp"] as? Int else {
                    return nil
                }

                // Convert UTC timestamp to Date
                let utcDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
                
                // Check if that date falls within today's local range
                guard utcDate >= localStart && utcDate <= localEnd else {
                    return nil
                }

                return UserLocationModel(from: value)
            }
            
            completion(todayModels)
        }
    }
    
//    func deleteUserAccount(userPhoneNumber: String, completion: @escaping (Bool) -> Void) {
//        self.ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: userPhoneNumber).observeSingleEvent(of: .value) { snapshot in
//            guard snapshot.exists() else {
//                completion(false) // No circles found for the user
//                return
//            }
//            
//            let group = DispatchGroup() // To ensure all deletions are complete
//            
//            for snap in snapshot.children.allObjects as! [DataSnapshot] {
//                group.enter() // Enter for circle deletion
//                
//                // Remove the circle where the user is the admin
//                self.ref.child("circles").child(snap.key).removeValue { error, _ in
//                    if let error = error {
//                        print("Error deleting circle: \(error.localizedDescription)")
//                    }
//                    group.leave() // Leave for circle deletion
//                }
//            }
//            
//            // Delete user from "members" section in all circles
//            self.ref.child("circles").observeSingleEvent(of: .value) { allCirclesSnapshot in
//                for circleSnap in allCirclesSnapshot.children.allObjects as! [DataSnapshot] {
//                    if circleSnap.childSnapshot(forPath: "members").hasChild(userPhoneNumber) {
//                        group.enter() // Enter for member removal
//                        self.ref.child("circles").child(circleSnap.key).child("members").child(userPhoneNumber).removeValue { error, _ in
//                            if let error = error {
//                                print("Error removing member: \(error.localizedDescription)")
//                            }
//                            group.leave() // Leave for member removal
//                        }
//                    }
//                }
//            }
//            
//            // Notify completion after all deletions
//            group.notify(queue: .main) {
//                completion(true)
//            }
//        }
//    }

    
//    func deleteUserAccount(userPhoneNumber: String, completion: @escaping (Bool) -> Void) {
//        self.ref.child("circles").queryOrdered(byChild: "admin").queryEqual(toValue: userPhoneNumber).observeSingleEvent(of: .value) { snapshot in
//            if snapshot.exists() {
//                for snap in snapshot.children.allObjects as! [DataSnapshot] {
//                    // Remove each circle where the user is the admin
//                    self.ref.child("circles").child(snap.key).removeValue { error, _ in
//                        if error != nil {
//                            completion(false)
//                            return
//                        }
//                        else{
//                            completion(true)
//                        }
//                    }
//                }
//            }
//        }
//    }

}


class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    var locationManager: CLLocationManager = CLLocationManager()
    var requestLocationAuthorizationCallback: ((CLAuthorizationStatus) -> Void)?
    var locationCallback: ((CLLocation) -> Void)?
    var lastRecordedLocation: CLLocation?
    
    override private init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    public func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        let currentStatus = CLLocationManager.authorizationStatus()
        
        switch currentStatus {
        case .notDetermined:
            // Request location access
            if #available(iOS 13.4, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.requestAlwaysAuthorization()
            }
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            completion(true)
        case .authorizedAlways:
            completion(true)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle changes in authorization status
        self.requestLocationAuthorizationCallback?(status)
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            startLocationUpdates()
        case .denied, .restricted:
            print("Location access denied or restricted.")
            // Optionally, show an alert to guide users to settings
        default:
            break
        }
    }
    
    func startMonitoring() {
        let currentStatus = CLLocationManager.authorizationStatus()
        switch currentStatus {
        case .notDetermined:
            // Request location access
            if #available(iOS 13.4, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.requestAlwaysAuthorization()
            }
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            break
        case .denied, .restricted:
            showSettingsAlert()
            break
        @unknown default:
            break
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(title: "Permission Required",
                                      message: "Please enable permissions in Settings",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }))

        // Present the alert from top ViewController
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alert, animated: true)
        }
    }
    
    private func startLocationUpdates() {
        startMonitazation()
        startUpdatingLocation()
        print("Started location updates.")
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func startMonitazation() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitazation() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func getCurrentLocation(completion: @escaping (CLLocation) -> Void) {
        locationCallback = completion
        locationManager.requestLocation() // This triggers didUpdateLocations
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        
        // If no previous location, store and return
        guard let lastLocation = lastRecordedLocation else {
            lastRecordedLocation = currentLocation
            return
        }
        //        print(lastLocation)
        
        //        getGoogleAddress(lat: lastLocation.coordinate.latitude, long: lastLocation.coordinate.longitude) { address in
        //            print(address)
        //        }
        
        // Calculate distance in meters
        let distance = currentLocation.distance(from: lastLocation)
        
        if distance >= 20 {
            print("📍 User moved \(distance) meters — updating location to database.")
            // ✅ Call your API here with `currentLocation.coordinate.latitude` & `.longitude`
            updateUserLocationToServer(lat: currentLocation.coordinate.latitude,
                                       long: currentLocation.coordinate.longitude)
            
            // Update last recorded location
            lastRecordedLocation = currentLocation
        } else {
            //print("🔁 Moved only \(distance) meters — not updating.")
        }
        
        locationCallback?(currentLocation)
        locationCallback = nil // Reset callback after use
    }
    
    func getGoogleAddress(lat: CLLocationDegrees, long: CLLocationDegrees, completion: @escaping (String?) -> Void) {
        let apiKey = "AIzaSyBMtqBk10Mt4qgTb71tvsYxGGZxkuAY7tY"
        let urlStr = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=\(apiKey)"
        
        guard let url = URL(string: urlStr) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❗️No data")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let formattedAddress = firstResult["formatted_address"] as? String {
                    completion(formattedAddress)
                } else {
                    completion(nil)
                }
            } catch {
                print("❌ JSON parse error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func updateUserLocationToServer(lat: CLLocationDegrees, long: CLLocationDegrees) {
        // Make your API call to update user location
        print("✅ Sending updated location to server: \(lat), \(long)")
        
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long)) { placemarks, error in
//            if let error = error {
//                //print("❌ Reverse geocoding failed: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let placemark = placemarks?.first else {
//                //print("❗️No address found")
//                return
//            }
//            
//            let address = """
//                                \(placemark.name ?? "")
//                                \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")
//                                \(placemark.postalCode ?? "") \(placemark.country ?? "")
//                                """
//            
//            print("📍 Full Address:\n\(address)")
//        }
        
//        FirebaseManager().updateLocationInFirebase(latitude: lat, longitude: long, userPhonenumber: Constants.USERDEFAULTS.getCurrentuserNumber())
        FirebaseManager().updateUserwiseLocationInFirebase(latitude: lat, longitude: long, userPhonenumber: Constants.USERDEFAULTS.getCurrentuserNumber())
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func getAddressFromLatLon(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil) // Return nil in case of an error
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks found")
                completion(nil) // Return nil if no placemarks are available
                return
            }
            
            // Build the address string
            var addressString = ""
            if let subLocality = placemark.subLocality {
                addressString += "\(subLocality), "
            }
            if let thoroughfare = placemark.thoroughfare {
                addressString += "\(thoroughfare), "
            }
            if let locality = placemark.locality {
                addressString += "\(locality), "
            }
            if let country = placemark.country {
                addressString += "\(country), "
            }
            if let postalCode = placemark.postalCode {
                addressString += "\(postalCode)"
            }
            
            // Trim trailing commas and whitespace
            addressString = addressString.trimmingCharacters(in: .whitespacesAndNewlines)
            completion(addressString)
        }
    }
}
