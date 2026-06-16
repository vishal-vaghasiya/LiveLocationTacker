//
//  NotificationManager.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//

import Foundation
import SwiftJWT

// MARK: - FCM Notification Manager

final class NotificationManager {
    
    static let shared = NotificationManager()
    private init() {}
    
    private let projectID = "ios---phone-tracker" // Replace with your Firebase Project ID
    
    // MARK: - Send Push Notification
    func sendPushNotification(
        type: NotificationType,
        fcmToken: String,
        title: String = AppName,
        body: String,
        code: String? = nil,
        completion: @escaping (Bool, String) -> Void
    ) {
        generateAccessToken { accessToken in
            guard let accessToken = accessToken else {
                completion(false, "Failed to generate access token.")
                return
            }
            
            let url = URL(string: "https://fcm.googleapis.com/v1/projects/\(self.projectID)/messages:send")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            var message: [String: Any] = [:]
            if type == .sos {
                message = [
                    "message": [
                        "token": fcmToken,
                        "notification": [
                            "title": title,
                            "body": body
                        ],
                        "data": [
                            "type": "\(type.rawValue)"
                        ]
                    ]
                ]
            } else if type == .disableChildMode {
                message = [
                    "message": [
                        "token": fcmToken,
                        "notification": [
                            "title": title,
                            "body": body
                        ],
                        "data": [
                            FirebaseKeys.code: code ?? "N/A",
                            FirebaseKeys.childNumber: DefaultManager.User.PHONE,
                            "type": "\(type.rawValue)",
                            FirebaseKeys.name: DefaultManager.User.NAME
                        ]
                    ]
                ]
            }
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []) else {
                completion(false, "Failed to encode notification payload.")
                return
            }
            
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(false, "Failed to send notification: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, "Invalid server response.")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    completion(true, "Notification sent successfully.")
                } else {
                    let message = "Failed with HTTP status code: \(httpResponse.statusCode)"
                    completion(false, message)
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Generate Access Token
    private func generateAccessToken(completion: @escaping (String?) -> Void) {
        guard let filePath = Bundle.main.path(forResource: "googleService", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
              let serviceAccount = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let clientEmail = serviceAccount["client_email"] as? String,
              let privateKey = serviceAccount["private_key"] as? String else {
            print("Error: Unable to load service account JSON.")
            completion(nil)
            return
        }
        
        let currentTime = Date().getCurrentUTCTimestampInfo().timestampSeconds
        let expirationTime = currentTime + 3600 // 1 hour
        
        let claims = GoogleJWTClaims(
            iss: clientEmail,
            scope: "https://www.googleapis.com/auth/firebase.messaging",
            aud: "https://oauth2.googleapis.com/token",
            exp: expirationTime,
            iat: currentTime
        )
        
        var jwt = JWT(claims: claims)
        guard let privateKeyData = privateKey.data(using: .utf8) else {
            print("Error: Unable to convert private key to Data.")
            completion(nil)
            return
        }
        
        let jwtSigner = JWTSigner.rs256(privateKey: privateKeyData)
        
        guard let jwtString = try? jwt.sign(using: jwtSigner) else {
            print("Error: Unable to sign JWT.")
            completion(nil)
            return
        }
        
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
    
}
