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
class PermissionManager {
    
    // MARK: - Contact Permission
    static func requestContactPermission(completion: @escaping (Bool) -> Void) {
        CNContactStore().requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static func checkContactPermission() -> Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
    
    // MARK: - Camera Permission
    static func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static func checkCameraPermission() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    // MARK: - Photo Library Permission
    static func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    static func checkPhotoLibraryPermission() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    // MARK: - Microphone Permission
    static func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static func checkMicrophonePermission() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    // MARK: - Location Permission
    static func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        let currentStatus = CLLocationManager.authorizationStatus()
        let locationManager: CLLocationManager = CLLocationManager()
        
        switch currentStatus {
        case .notDetermined:
            // Request location access
            if #available(iOS 13.4, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.requestAlwaysAuthorization()
            }
        case .authorizedAlways, .authorizedWhenInUse:
            completion(true)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    static func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle changes in authorization status
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            manager.startMonitoringSignificantLocationChanges()
        case .denied, .restricted:
            print("Location access denied or restricted.")
            // Optionally, show an alert to guide users to settings
        default:
            break
        }
    }
    
    static func checkLocationPermission() -> Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    // MARK: - Music Library Permission
    static func requestMusicLibraryPermission(completion: @escaping (Bool) -> Void) {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    static func checkMusicLibraryPermission() -> Bool {
        return MPMediaLibrary.authorizationStatus() == .authorized
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
    
    static func checkNotificationPermission() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isAuthorized = false
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            isAuthorized = settings.authorizationStatus == .authorized
            semaphore.signal() // Allow the thread to proceed
        }
        
        // Wait for the async operation to complete
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
    
    static func checkMotionPermission() -> Bool {
        return CMMotionActivityManager.authorizationStatus() == .authorized
    }
}
