//
//  BatteryManager.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//

import UIKit

final class BatteryManager {
    
    static let shared = BatteryManager()
    let firebaseManager = FirebaseManager.shared
    
    private init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func batteryLevelDidChange(notification: Notification) {
        let level = Int(UIDevice.current.batteryLevel * 100)
        
        // You can post your own notification or handle it here globally
        firebaseManager.updateBatteryLevel(batteryLevel: level)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
