//
//  PushNotificationManager.swift
//
//  Created by Apple on 20/12/23.
//

import Foundation
import FirebaseMessaging
import UIKit

class PushNotificationManager: NSObject, ObservableObject {

    static let shared = PushNotificationManager()

    override init() {
        super.init()
        Messaging.messaging().delegate = self // 1
    }

    func requestAuthorization(completionHandler: @escaping () -> Void) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().getNotificationSettings { settings in // 2
            switch settings.authorizationStatus {
            case .denied:
                guard
                    let url = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(url)
                else {
                    return
                }
                DispatchQueue.main.async {
                    UIApplication.shared.open(url) // 3
                    completionHandler()
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in // 4
                    guard granted else { return completionHandler() }
                    DispatchQueue.main.async {
                        completionHandler()
                    }
                }
            case .authorized:
                DispatchQueue.main.async {
                    completionHandler() // 5
                }
            case .provisional, .ephemeral:
                completionHandler()
            @unknown default:
                completionHandler()
            }
        }
    }
}

extension PushNotificationManager: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("FcmToken == > \(fcmToken)")
        print("Firebase registration token: \(String(describing: fcmToken))")
        FCMTokenManager.shared.currentToken = fcmToken // 6
        DefaultManager.User.FCM_TOKEN = fcmToken
    }
}


 // FCMToken∫

class FCMTokenManager {

    static let shared = FCMTokenManager()

    private enum UserDefaultKey: String {
        case fcmToken
    }

    var currentToken: String? {
        get {
            UserDefaults.standard.string(forKey: UserDefaultKey.fcmToken.rawValue)
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultKey.fcmToken.rawValue)
        }
    }
}
