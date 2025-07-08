//
//  PermissionManager.swift
//
//  Created by DREAMWORLD on 21/12/23.
//

import Foundation
import AVFoundation
import Photos
import Contacts
import CoreLocation
import Network
import MediaPlayer
import CoreMotion
import UserNotifications

class PermissionManager {
    
    // MARK: - Contact Permission
    
    static func requestContactPermission(completion: @escaping (Bool) -> Void) {
        CNContactStore().requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static var isContactPermissionGranted: Bool {
        CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
    
    // MARK: - Camera Permission
    
    static func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static var isCameraPermissionGranted: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    // MARK: - Location Permission
    
    static var isLocationPermissionGranted: Bool {
        let locationManager = CLLocationManager()
        let currentStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            currentStatus = locationManager.authorizationStatus
        } else {
            currentStatus = CLLocationManager.authorizationStatus()
        }
        return currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways
    }
    
    // MARK: - Notification Permission
    
    static func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(granted)
                }
            }
        }
    }
    
    static var isNotificationPermissionGranted: Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isAuthorized = false
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            isAuthorized = settings.authorizationStatus == .authorized
            semaphore.signal()
        }
        
        semaphore.wait()
        return isAuthorized
    }
    
    // MARK: - Motion Permission
    
    static func requestMotionPermission(completion: @escaping (Bool) -> Void) {
        let motionManager = CMMotionActivityManager()
        if CMMotionActivityManager.authorizationStatus() == .notDetermined {
            motionManager.startActivityUpdates(to: OperationQueue.main) { _ in
                motionManager.stopActivityUpdates()
                completion(CMMotionActivityManager.authorizationStatus() == .authorized)
            }
        } else {
            completion(CMMotionActivityManager.authorizationStatus() == .authorized)
        }
    }
    
    static var isMotionPermissionGranted: Bool {
        CMMotionActivityManager.authorizationStatus() == .authorized
    }
}
