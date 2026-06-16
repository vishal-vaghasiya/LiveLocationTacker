//
//  CameraPermission.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import AVFoundation

class CameraPermission: AppPermissionCheckable {
    func isPermissionGranted(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        completion(status == .authorized)
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}
