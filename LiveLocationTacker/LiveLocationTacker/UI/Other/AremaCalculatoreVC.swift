//
//  AremaCalculatoreVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 19/11/24.
//

import UIKit
import MapKit

class AremaCalculatoreVC: UIViewController , MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lbl_areaunit: UILabel!
    @IBOutlet weak var lbl_distanceunit: UILabel!
    @IBOutlet weak var dropdownView: UIView!
    
    
    var polygonPoints: [CLLocationCoordinate2D] = []
    var polygonOverlay: MKPolygon?
    var pointAnnotations: [MKPointAnnotation] = []
    var distanceAnnotations: [MKPointAnnotation] = []
    var polylineOverlay: MKPolyline?
    var currentMapType: MKMapType = .standard
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.mapType = .hybrid
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        redirectCurrentLocation()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
    }
    
    @IBAction func btnMapToolsAction(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        switch sender.tag {
        case 0:
            zoomIn()
        case 1:
            zoomOut()
        case 2:
            resetMap()
        case 3:
            setMapeType()
        case 4:
            redirectCurrentLocation()
        case 5:
            removeLastPolygon()
        default:
            break
        }
    }
    
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: mapView)
        let coordinate = mapView.convert(tapLocation, toCoordinateFrom: mapView)
        
        // Add point to the array
        polygonPoints.append(coordinate)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Point \(polygonPoints.count)"
        pointAnnotations.append(annotation)
        mapView.addAnnotation(annotation)
        
        // Update the polygon overlay
        updatePolygonOverlay()
        updateDistanceLabels()
        
        let totalDistance = calculateTotalLineDistance(points: polygonPoints)
        lbl_distanceunit.text = "\(totalDistance.rounded(toPlaces: 2))"
        
        print("Total Line Distance: \(totalDistance) meters")
    }
    
    func calculateTotalLineDistance(points: [CLLocationCoordinate2D]) -> Double {
        guard points.count > 1 else { return 0 } // Need at least 2 points
        
        var totalDistance: Double = 0
        for i in 0..<points.count - 1 {
            let start = CLLocation(latitude: points[i].latitude, longitude: points[i].longitude)
            let end = CLLocation(latitude: points[i + 1].latitude, longitude: points[i + 1].longitude)
            totalDistance += start.distance(from: end) // Distance in meters
        }
        return totalDistance
    }
    
    func updateDistanceLabels() {
        // Remove old distance annotations
        mapView.removeAnnotations(distanceAnnotations)
        distanceAnnotations.removeAll()

        guard polygonPoints.count > 1 else { return } // Need at least 2 points

        for i in 0..<polygonPoints.count {
            let start = polygonPoints[i]
            let end = polygonPoints[(i + 1) % polygonPoints.count] // Wrap back to the start for the last line
            let distance = calculateDistance(start: start, end: end)

            // Calculate midpoint for placing the label
            let midLatitude = (start.latitude + end.latitude) / 2
            let midLongitude = (start.longitude + end.longitude) / 2
            let midPoint = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)

            // Add an annotation at the midpoint
            let distanceAnnotation = MKPointAnnotation()
            distanceAnnotation.coordinate = midPoint
            distanceAnnotation.title = "\(distance) km"
            distanceAnnotations.append(distanceAnnotation)
            mapView.addAnnotation(distanceAnnotation)
        }
    }
    
    func calculateDistance(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> Double {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        // Calculate the distance in meters
        let distanceInMeters = startLocation.distance(from: endLocation)
        
        // Convert meters to kilometers and round the result
        let distanceInKilometers = distanceInMeters / 1000
        return distanceInKilometers.rounded(toPlaces: 2) // Rounding to 2 decimal places
    }
    
    func updatePolygonOverlay() {
        // Remove the previous polygon and polyline
        if let overlay = polygonOverlay {
            mapView.removeOverlay(overlay)
        }
        if let polyline = polylineOverlay {
            mapView.removeOverlay(polyline)
        }

        // If fewer than 3 points, add a polyline instead of a polygon
        if polygonPoints.count < 3 {
            
            if polygonPoints.count > 1 {
                dropdownView.isHidden = false
                
                polylineOverlay = MKPolyline(coordinates: polygonPoints, count: polygonPoints.count)
                if let polyline = polylineOverlay {
                    mapView.addOverlay(polyline)
                }
            }
            
        } else {
            // Create a new polygon
            polygonOverlay = MKPolygon(coordinates: polygonPoints, count: polygonPoints.count)
            if let overlay = polygonOverlay {
                mapView.addOverlay(overlay)
            }

            // Calculate the area and print
            let area = calculateAreaOfPolygon(points: polygonPoints)
            self.lbl_areaunit.text = "\(area.rounded(toPlaces: 2))"
            print("Area: \(area) square meters")
        }
    }
    
    func calculateAreaOfPolygon(points: [CLLocationCoordinate2D]) -> Double {
        guard points.count > 2 else { return 0 } // Need at least 3 points to form a polygon
        
        let earthRadius: Double = 6378137.0 // Earth's radius in meters
        
        var area: Double = 0
        let latitudes = points.map { $0.latitude }
        let longitudes = points.map { $0.longitude }

        // Use Shoelace Theorem to calculate the area
        for i in 0..<points.count {
            let j = (i + 1) % points.count
            let lat1 = latitudes[i] * .pi / 180
            let lon1 = longitudes[i] * .pi / 180
            let lat2 = latitudes[j] * .pi / 180
            let lon2 = longitudes[j] * .pi / 180

            // Calculation based on longitude and latitude
            area += lon1 * lat2 - lon2 * lat1
        }

        area = abs(area) / 2.0
        area *= earthRadius * earthRadius // in square meters

        // Convert square meters to square feet
        let areaInSquareFeet = area * 10.7639 // 1 square meter = 10.7639 square feet
        return areaInSquareFeet
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Check if the annotation is the user's location
        if annotation is MKUserLocation {
            let identifier = "UserLocationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
                
                // Set custom image for user location pin
                annotationView?.image = UIImage(named: "pin-map") // Your custom image
                annotationView?.bounds.size = CGSize(width: 50, height: 50)
            }
            
            return annotationView
        }
        
        if let title = annotation.title, title?.contains("km") == true {
            // Distance label view
            let identifier = "DistanceLabel"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
                
                // Custom label
                let label = UILabel()
                label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 12)
                label.textAlignment = .center
                label.layer.cornerRadius = 5
                label.layer.masksToBounds = true
                label.translatesAutoresizingMaskIntoConstraints = false
                annotationView?.addSubview(label)
                
                // Constraints for the label
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: annotationView!.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: annotationView!.centerYAnchor),
                    label.widthAnchor.constraint(equalToConstant: 80),
                    label.heightAnchor.constraint(equalToConstant: 25)
                ])
                label.tag = 1
            }
            
            if let label = annotationView?.viewWithTag(1) as? UILabel {
                label.text = title
            }
            return annotationView
        }
        
        // Regular point pin
        let identifier = "CustomPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            (annotationView as? MKPinAnnotationView)?.pinTintColor = .red
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    // Render the polygon on the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 1
            return renderer
        } 
        else if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
}


extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//MARK: -  MAPTOOLS

extension AremaCalculatoreVC {
    
    func zoomIn() {
        var region = mapView.region
        let minDelta: CLLocationDegrees = 0.001  // Minimum zoom level
        
        // Only zoom in if we're not already at the max zoom level
        if region.span.latitudeDelta > minDelta && region.span.longitudeDelta > minDelta {
            region.span.latitudeDelta /= 2.0
            region.span.longitudeDelta /= 2.0
            
            // Ensure that the new region is still valid (we're not trying to zoom too much)
            region.span.latitudeDelta = max(region.span.latitudeDelta, minDelta)
            region.span.longitudeDelta = max(region.span.longitudeDelta, minDelta)
            
            // Set the new region
            mapView.setRegion(region, animated: true)
        } else {
            print("Cannot zoom in further: already at max zoom.")
        }
    }

    func zoomOut() {
        var region = mapView.region
        let maxDelta: CLLocationDegrees = 180.0  // Maximum zoom level (entire world)
        
        // Only zoom out if we're not already at the min zoom level
        if region.span.latitudeDelta < maxDelta && region.span.longitudeDelta < maxDelta {
            region.span.latitudeDelta *= 2.0
            region.span.longitudeDelta *= 2.0
            
            // Ensure that the new region is still valid (we're not trying to zoom too much)
            region.span.latitudeDelta = min(region.span.latitudeDelta, maxDelta)
            region.span.longitudeDelta = min(region.span.longitudeDelta, maxDelta)
            
            // Set the new region
            mapView.setRegion(region, animated: true)
        } else {
            print("Cannot zoom out further: already at min zoom.")
        }
    }
    
    func setMapeType(){
        switch currentMapType {
        case .standard:
            currentMapType = .satellite
        case .satellite:
            currentMapType = .hybrid
        case .hybrid:
            currentMapType = .standard
        default:
            currentMapType = .standard
        }
        mapView.mapType = currentMapType
    }
    
    func resetMap() {
        // Clear all annotations and overlays
        mapView.removeAnnotations(pointAnnotations)
        mapView.removeAnnotations(distanceAnnotations)
        pointAnnotations.removeAll()
        distanceAnnotations.removeAll()
        dropdownView.isHidden = true
        lbl_areaunit.text = "0.0"
        lbl_distanceunit.text = "0.0"
        
        if let overlay = polygonOverlay {
            mapView.removeOverlay(overlay)
        }
        polygonPoints.removeAll()
        polygonOverlay = nil
        if let polyline = polylineOverlay {
            mapView.removeOverlay(polyline)
        }
    }
    
    func redirectCurrentLocation(){
        guard let userLocation = mapView.userLocation.location else {
            print("User location not available.")
            return
        }
        
      //  let coordinates = CLLocation(latitude: 21.5087484, longitude: 71.7197539)
        
        let region = MKCoordinateRegion(center: userLocation.coordinate,latitudinalMeters: 500,longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    func removeLastPolygon() {
        // Ensure there are points to form a polygon
        guard polygonPoints.count > 0 else {
            print("Not enough points to remove a polygon")
            return
        }
        
        // Remove the last polygon overlay if exists
        if let overlay = polygonOverlay {
            mapView.removeOverlay(overlay)
            polygonOverlay = nil
        }
        
        // Remove the corresponding point annotation (last pin)
        if let lastPin = pointAnnotations.last {
            mapView.removeAnnotation(lastPin)
            pointAnnotations.removeLast()
        }
        
        // Remove the corresponding distance label annotation (last distance annotation)
        if let lastDistanceAnnotation = distanceAnnotations.last {
            mapView.removeAnnotation(lastDistanceAnnotation)
            distanceAnnotations.removeLast()
        }
        
        // Remove the last point forming the polygon
        polygonPoints.removeLast()
        updatePolygonOverlay2()
    }
    
    func updatePolygonOverlay2() {
        // If 3 or more points remain, form a polygon
        if polygonPoints.count >= 3 {
            polygonOverlay = MKPolygon(coordinates: polygonPoints, count: polygonPoints.count)
            if let overlay = polygonOverlay {
                mapView.addOverlay(overlay)
            }
        }
        // If only 2 points remain, draw a polyline instead of a polygon
        else if polygonPoints.count == 2 {
            updatePolylineOverlay()
        }
        else {
            resetMap()
        }
    }

    func updatePolylineOverlay() {
        // If there are points remaining, draw a polyline instead of a polygon
        if polygonPoints.count > 0 {
            polylineOverlay = MKPolyline(coordinates: polygonPoints, count: polygonPoints.count)
            if let overlay = polylineOverlay {
                mapView.addOverlay(overlay)
            }
        }
    }

}
