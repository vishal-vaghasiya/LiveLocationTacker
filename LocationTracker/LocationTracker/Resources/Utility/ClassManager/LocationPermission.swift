//
//  LocationPermission.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import CoreLocation

class LocationPermission: NSObject, AppPermissionCheckable {
    
    private let locationManager = CLLocationManager()
    private var permissionCompletion: ((Bool) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func isPermissionGranted(completion: @escaping (Bool) -> Void) {
        let status = locationManager.authorizationStatus
        let granted = status == .authorizedAlways || status == .authorizedWhenInUse
        completion(granted)
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        self.permissionCompletion = completion
        
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            completion(true)
        default:
            completion(false)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationPermission: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let granted = status == .authorizedAlways || status == .authorizedWhenInUse
        permissionCompletion?(granted)
        permissionCompletion = nil
    }
}
