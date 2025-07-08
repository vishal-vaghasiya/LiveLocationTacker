//
//  LocationManagerNew.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 08/07/25.
//

import CoreLocation
import UIKit

class LocationManagerNew: NSObject {
    
    static let shared = LocationManagerNew()
    
    let locationManager = CLLocationManager()
    var authorizationStatusHandler: ((CLAuthorizationStatus) -> Void)?
    var locationUpdateHandler: ((CLLocation) -> Void)?
    var lastRecordedLocation: CLLocation?
    
    override private init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    // MARK: - Location Authorization
    
    public func requestLocationAuthorization(completion: @escaping (Bool) -> Void) {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            if #available(iOS 13.4, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.requestAlwaysAuthorization()
            }
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            completion(true)
        case .authorizedAlways:
            completion(true)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - Location Monitoring
    
    func startMonitoringLocationChanges() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            if #available(iOS 13.4, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.requestAlwaysAuthorization()
            }
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            break
        case .denied, .restricted:
            showSettingsAlert()
            break
        @unknown default:
            break
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(title: "Permission Required",
                                      message: "Please enable permissions in Settings",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        
        // Present the alert from top ViewController
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alert, animated: true)
        }
    }
    
    private func startLocationUpdates() {
        startMonitoringLocationChanges()
        startUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopMonitoringLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func fetchCurrentLocation(completion: @escaping (CLLocation) -> Void) {
        locationUpdateHandler = completion
        locationManager.requestLocation() // This triggers didUpdateLocations
    }
    
    private func uploadLocationToServer(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        FirebaseManager.shared.saveUserLocationHistory(latitude: latitude, longitude: longitude)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManagerNew: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatusHandler?(status)
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            startLocationUpdates()
        case .denied, .restricted:
            print("Location access denied or restricted.")
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        guard let lastLocation = lastRecordedLocation else {
            lastRecordedLocation = currentLocation
            return
        }

        let distance = currentLocation.distance(from: lastLocation)
        
        if distance >= 20 {
            print("📍 User moved \(distance) meters — updating location to database.")
            uploadLocationToServer(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            lastRecordedLocation = currentLocation
        }
        
        locationUpdateHandler?(currentLocation)
        locationUpdateHandler = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

// MARK: - Reverse Geocoding

extension LocationManagerNew {
    
    func fetchAddressFromGoogleAPI(lat: CLLocationDegrees, long: CLLocationDegrees, completion: @escaping (String?) -> Void) {
        let apiKey = "AIzaSyBMtqBk10Mt4qgTb71tvsYxGGZxkuAY7tY"
        let urlStr = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=\(apiKey)"
        
        guard let url = URL(string: urlStr) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❗️No data")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let formattedAddress = firstResult["formatted_address"] as? String {
                    completion(formattedAddress)
                } else {
                    completion(nil)
                }
            } catch {
                print("❌ JSON parse error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func reverseGeocodeLocation(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks found")
                completion(nil)
                return
            }
            
            var addressString = ""
            if let subLocality = placemark.subLocality {
                addressString += "\(subLocality), "
            }
            if let thoroughfare = placemark.thoroughfare {
                addressString += "\(thoroughfare), "
            }
            if let locality = placemark.locality {
                addressString += "\(locality), "
            }
            if let country = placemark.country {
                addressString += "\(country), "
            }
            if let postalCode = placemark.postalCode {
                addressString += "\(postalCode)"
            }
            
            addressString = addressString.trimmingCharacters(in: .whitespacesAndNewlines)
            completion(addressString)
        }
    }
}
