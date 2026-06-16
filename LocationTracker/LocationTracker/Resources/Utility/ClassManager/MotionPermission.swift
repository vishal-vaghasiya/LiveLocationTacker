//
//  MotionPermission.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import CoreMotion

class MotionPermission: AppPermissionCheckable {
    private let motionManager = CMMotionActivityManager()
    
    func isPermissionGranted(completion: @escaping (Bool) -> Void) {
        let status = CMMotionActivityManager.authorizationStatus()
        completion(status == .authorized)
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        // Requesting motion data to trigger permission prompt
        motionManager.queryActivityStarting(from: Date(), to: Date(), to: .main) { _, error in
            completion(error == nil)
        }
    }
}
