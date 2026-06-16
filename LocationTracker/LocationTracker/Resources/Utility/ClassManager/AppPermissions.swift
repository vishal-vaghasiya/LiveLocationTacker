//
//  AppPermissions.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import Foundation
import CoreLocation
import AVFoundation
import UserNotifications
import CoreMotion
import FirebaseMessaging

enum AppPermissionType: Int {
    case location = 0
    case camera = 1
    case notification = 2
    case motion = 3
}

private let permissions: [AppPermissionType: AppPermissionCheckable] = [
    .location: LocationPermission(),
    .camera: CameraPermission(),
    .notification: NotificationPermission(),
    .motion: MotionPermission()
]

extension AppPermissionType {
    var displayName: String {
        switch self {
        case .location: return "Location"
        case .camera: return "Camera"
        case .notification: return "Notification"
        case .motion: return "Motion"
        }
    }
}

protocol AppPermissionCheckable {
    func isPermissionGranted(completion: @escaping (Bool) -> Void)
}

class AppPermissionManager: NSObject {
    static let shared = AppPermissionManager()
    
    override init() {
        super.init()
        Messaging.messaging().delegate = self // 1
    }
    
    func checkPermission(_ type: AppPermissionType, completion: @escaping (Bool) -> Void) {
        permissions[type]?.isPermissionGranted(completion: completion)
    }
    
    func requestPermission(for type: AppPermissionType, completion: @escaping (Bool) -> Void) {
        switch type {
        case .location:
            (permissions[.location] as? LocationPermission)?.requestPermission(completion: completion)
        case .camera:
            (permissions[.camera] as? CameraPermission)?.requestPermission(completion: completion)
        case .notification:
            (permissions[.notification] as? NotificationPermission)?.requestPermission(completion: completion)
        case .motion:
            (permissions[.motion] as? MotionPermission)?.requestPermission(completion: completion)
        }
    }

    func checkAllPermissions(completion: @escaping ([AppPermissionType: Bool]) -> Void) {
        var results: [AppPermissionType: Bool] = [:]
        let group = DispatchGroup()
        
        for (type, checker) in permissions {
            group.enter()
            checker.isPermissionGranted { granted in
                results[type] = granted
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }

    func isPermissionGranted(_ type: AppPermissionType) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isGranted: Bool = false

        checkPermission(type) { granted in
            isGranted = granted
            semaphore.signal()
        }

        semaphore.wait()
        return isGranted
    }
}
extension AppPermissionManager: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        DefaultManager.User.FCM_TOKEN = fcmToken
        if DefaultManager.IS_INITIAL_SETUP {
            FirebaseManager.shared.updateFCMToken()
        }
    }
}
