//
//  CompassVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 19/11/24.
//

import UIKit
import CoreLocation

class CompassVC: UIViewController {

    @IBOutlet weak var compass_view: UIView!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var latitudeAndLongitudeLabel: UILabel!
    @IBOutlet weak var lbl_address: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    var lastAngle: Int = 0 // To store the last angle for comparison
    var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .medium)
    
    private lazy var dScaView: DegreeScaleView = {
        let viewF = CGRect(x: 0, y: compass_view.frame.origin.y, width: compass_view.frame.width, height: compass_view.frame.height)
        let scaleV = DegreeScaleView(frame: viewF)
        return scaleV
    }()
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        compass_view.addSubview(dScaView)
        createLocationManager()
        setRightSideButtonInNavigationBar()
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        
        generator = UIImpactFeedbackGenerator(style: .medium)
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        super.viewWillDisappear(animated)
        
        generator = nil
    }
    
    func createLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = 0
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

}


// MARK: - Update Location Information

extension CompassVC {
    
    private func update(_ newHeading: CLHeading) {
        
        /// Heading
        let theHeading: CLLocationDirection = newHeading.magneticHeading > 0 ? newHeading.magneticHeading : newHeading.trueHeading
        
        /// Angle
        let angle = Int(theHeading)
        
        switch angle {
        case 0:
            self.directionLabel.text = "North"
        case 90:
            self.directionLabel.text = "East"
        case 180:
            self.directionLabel.text = "South"
        case 270:
            self.directionLabel.text = "West"
        default:
            break
        }
        
        if angle > 0 && angle < 90 {
            self.directionLabel.text = "Northeast"
        } else if angle > 90 && angle < 180 {
            self.directionLabel.text = "Southeast"
        } else if angle > 180 && angle < 270 {
            self.directionLabel.text = "Southwest"
        } else if angle > 270 {
            self.directionLabel.text = "Northwest"
        }
    }
    
    private func heading(_ heading: Float, fromOrientation orientation: UIDeviceOrientation) -> Float {
        
        var realHeading: Float = heading
        
        switch orientation {
        case .portrait:
            break
        case .portraitUpsideDown:
            realHeading = heading - 180
        case .landscapeLeft:
            realHeading = heading + 90
        case .landscapeRight:
            realHeading = heading - 90
        default:
            break
        }
        if realHeading > 360 {
            realHeading -= 360
        } else if realHeading < 0.0 {
            realHeading += 366
        }
        return realHeading
    }
}



// MARK: - CLLocationManagerDelegate
extension CompassVC: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var currLocation: CLLocation = CLLocation()
        currLocation = locations.last!
        
        let longitudeStr = String(format: "%3.4f", currLocation.coordinate.longitude)
        let latitudeStr = String(format: "%3.4f", currLocation.coordinate.latitude)
        let altitudeStr = "\(Int(currLocation.altitude))"
        let newLongitudeStr = longitudeStr.DegreeToString(d: Double(longitudeStr)!)
        let newlatitudeStr = latitudeStr.DegreeToString(d: Double(latitudeStr)!)
        
        print("Latitude: \(currLocation.coordinate.latitude)")
        print("Longitude: \(currLocation.coordinate.longitude)")
        
        self.latitudeAndLongitudeLabel.text = "Latitude \(newlatitudeStr)  Longitude \(newLongitudeStr)"
        self.altitudeLabel.text = "Altitude: \(altitudeStr) meters"
        
        LocationManager.shared.getAddressFromLatLon(latitude: currLocation.coordinate.latitude,
                                                    longitude: currLocation.coordinate.longitude) { adress in
            self.lbl_address.text = adress
        } 
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let device = UIDevice.current
        
        if newHeading.headingAccuracy > 0 {
            let magneticHeading: Float = heading(Float(newHeading.magneticHeading), fromOrientation: device.orientation)
            let headi: Float = -1.0 * Float.pi * Float(newHeading.magneticHeading) / 180.0

            let currentAngle = Int(magneticHeading)
            self.angleLabel.text = "\(Int(magneticHeading))"
            dScaView.resetDirection(CGFloat(headi))
            update(newHeading)
            
            if currentAngle % 10 == 0 && currentAngle != lastAngle {
                lastAngle = currentAngle
                generator?.impactOccurred()
            }
        }
    }
   
    // Check if the device requires calibration, usually when there is external magnetic interference
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    // Location manager failure callback
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed....\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
 
        if status == .denied || status == .restricted {
            // Handle location authorization denial
            let alertVC = UIAlertController(title: "Alert", message: "Please enable location services in Settings.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
}

extension String {
    
    func DegreeToString(d: Double) -> String {
        /// Degree
        let degree = Int(d)
        print("Degree: \(degree)°")
        /// Temporary minute
        let tempMinute = Float(d - Double(degree)) * 60
        /// Minute
        let minutes = Int(tempMinute)   // Round down
        print("Minute: \(minutes)′")
        /// Second
        let second = Int((tempMinute - Float(minutes)) * 60)
        print("Second: \(second)\"")
        return "\(degree)°\(minutes)′\(second)″"
    }
}

