//
//  LocationManager.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 03/07/25.
//

import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    var locationManager: CLLocationManager = CLLocationManager()
    var requestLocationAuthorizationCallback: ((CLAuthorizationStatus) -> Void)?
    var locationCallback: ((CLLocation) -> Void)?
    var lastRecordedLocation: CLLocation?
    
    override private init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    public func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        let currentStatus = CLLocationManager.authorizationStatus()
        
        switch currentStatus {
        case .notDetermined:
            // Request location access
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
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle changes in authorization status
        self.requestLocationAuthorizationCallback?(status)
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            startLocationUpdates()
        case .denied, .restricted:
            print("Location access denied or restricted.")
            // Optionally, show an alert to guide users to settings
        default:
            break
        }
    }
    
    func startMonitoring() {
        let currentStatus = CLLocationManager.authorizationStatus()
        switch currentStatus {
        case .notDetermined:
            // Request location access
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
        startMonitazation()
        startUpdatingLocation()
        print("Started location updates.")
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func startMonitazation() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitazation() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func getCurrentLocation(completion: @escaping (CLLocation) -> Void) {
        locationCallback = completion
        locationManager.requestLocation() // This triggers didUpdateLocations
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        
        // If no previous location, store and return
        guard let lastLocation = lastRecordedLocation else {
            lastRecordedLocation = currentLocation
            return
        }
        //        print(lastLocation)
        
        //        getGoogleAddress(lat: lastLocation.coordinate.latitude, long: lastLocation.coordinate.longitude) { address in
        //            print(address)
        //        }
        
        // Calculate distance in meters
        let distance = currentLocation.distance(from: lastLocation)
        
        if distance >= 20 {
            print("📍 User moved \(distance) meters — updating location to database.")
            // ✅ Call your API here with `currentLocation.coordinate.latitude` & `.longitude`
            updateUserLocationToServer(lat: currentLocation.coordinate.latitude,
                                       long: currentLocation.coordinate.longitude)
            
            // Update last recorded location
            lastRecordedLocation = currentLocation
        } else {
            //print("🔁 Moved only \(distance) meters — not updating.")
        }
        
        locationCallback?(currentLocation)
        locationCallback = nil // Reset callback after use
    }
    
    func getGoogleAddress(lat: CLLocationDegrees, long: CLLocationDegrees, completion: @escaping (String?) -> Void) {
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
    
    func updateUserLocationToServer(lat: CLLocationDegrees, long: CLLocationDegrees) {
        // Make your API call to update user location
        FirebaseManager.shared.updateUserwiseLocationInFirebase(latitude: lat, longitude: long, userPhonenumber: DefaultManager.User.PHONE)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func getAddressFromLatLon(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil) // Return nil in case of an error
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks found")
                completion(nil) // Return nil if no placemarks are available
                return
            }
            
            // Build the address string
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
            
            // Trim trailing commas and whitespace
            addressString = addressString.trimmingCharacters(in: .whitespacesAndNewlines)
            completion(addressString)
        }
    }
}
