//
//  NotificationPermission.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UserNotifications

class NotificationPermission: AppPermissionCheckable {
    func isPermissionGranted(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}
