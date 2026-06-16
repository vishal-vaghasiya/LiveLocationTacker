//
//  ProximityVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 13/08/25.
//

import UIKit
import CoreLocation
import MapKit

class ProximityVC: UIViewController {

    // MARK: - Zoom Limits
    private let minSpan: CLLocationDegrees = 0.001
    private let maxSpan: CLLocationDegrees = 100
    
    // MARK: - OUTLET
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - PROPERTY
    var alerts: [ProximityAlert] = []
    var currentMapType: MKMapType = .standard
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseManager.shared.isUserInAnyChildCircle()
        Loader.show("")
        alerts = CoreDataManager.shared.fetchProximityAlerts()
        Loader.hide()
        loadPinsOnMap()
        after(2) {
            self.presentAlertList()
        }
    }
    
    // MARK: - Map Pin Logic
    private func loadPinsOnMap() {
        // Remove existing annotations except user location
        mapView.removeAnnotations(mapView.annotations)
        // Add pins for each ProximityAlert
        for alert in alerts {
            let pin = getPin(type: "\(alert.type)")
            let coordinate = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
            let annotation = ImageAnnotation(coordinate: coordinate, title: alert.name, subTitle: "", image: pin.0)
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dismissPresentedSheetIfNeeded()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        mapView.delegate = self
        LocationManager.shared.fetchCurrentLocation { location in
            self.centerMapOnCoordinate(location.coordinate)
        }
    }
    
    func centerMapOnCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func mapStyleButtonClick(_ sender: UIButton) {
        presentMapStyle()
    }
    
    @IBAction func zoomInButtonClick(_ sender: UIButton) {
        var region = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        region.span.latitudeDelta = max(minSpan, min(maxSpan, region.span.latitudeDelta))
        region.span.longitudeDelta = max(minSpan, min(maxSpan, region.span.longitudeDelta))
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomOutButtonClick(_ sender: UIButton) {
        var region = mapView.region
        region.span.latitudeDelta *= 2.0
        region.span.longitudeDelta *= 2.0
        region.span.latitudeDelta = max(minSpan, min(maxSpan, region.span.latitudeDelta))
        region.span.longitudeDelta = max(minSpan, min(maxSpan, region.span.longitudeDelta))
        mapView.setRegion(region, animated: true)
    }
    
    
    // MARK: - OTHER
    private func presentAlertList() {
        let vc = StoryboardScene.Proximity.proximityAlertListVC.instantiate()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.isModalInPresentation = true
        nav.navigationBar.isHidden = true
        vc.onAddButtonTapped = {
            self.dismissPresentedAlertSheetIfNeeded()
            AdManager.shared.showInterstitialAd(from: self) {
                let vc = StoryboardScene.Proximity.addProximityVC.instantiate()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        vc.onDidSelectTapped = { data in
            self.dismissPresentedAlertSheetIfNeeded()
            AdManager.shared.showInterstitialAd(from: self) {
                let vc = StoryboardScene.Proximity.proximityInfoVC.instantiate()
                vc.data = data
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        present(nav, animated: true)
    }
    
    private func dismissPresentedAlertSheetIfNeeded() {
        if let presented = self.presentedViewController as? UINavigationController {
            if presented.viewControllers.first is ProximityAlertListVC {
                presented.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func presentMapStyle() {
        let vc = StoryboardScene.Circle.popupMapSettings.instantiate()
        vc.selectedMapType = currentMapType
        vc.onMapSelectedTapped = { type in
            self.dismissPresentedMapSeetingsSheetIfNeeded()
            self.currentMapType = type
            self.mapView.mapType = type
        }
        vc.onMapPreview = { type in
            self.mapView.mapType = type
        }
        vc.onMapCancelTapped = {
            self.dismissPresentedMapSeetingsSheetIfNeeded()
            self.mapView.mapType = self.currentMapType
        }
        vc.modalPresentationStyle = .pageSheet
        vc.isModalInPresentation = true
        vc.presentationController?.delegate = self
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 300 })]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        if let presented = self.presentedViewController {
            presented.dismiss(animated: false) {
                self.present(vc, animated: true)
            }
        } else {
            self.present(vc, animated: true)
        }
    }
    
    private func dismissPresentedMapSeetingsSheetIfNeeded() {
        if let presented = self.presentedViewController {
            if presented is PopupMapSettings {
                presented.dismiss(animated: true, completion: {
                    self.presentAlertList()
                })
            }
        }
    }
    
    private func dismissPresentedSheetIfNeeded() {
        if let presented = self.presentedViewController as? UINavigationController {
            if presented.viewControllers.first is PopupMapSettings || presented.viewControllers.first is ProximityAlertListVC {
                presented.dismiss(animated: true, completion: nil)
            }
        } else if let presented = self.presentedViewController  {
            if presented is PopupMapSettings {
                presented.dismiss(animated: true, completion:  nil)
            }
        }
    }
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension ProximityVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let sheet = TabSheetPresentationController(presentedViewController: presented, presenting: source)
        sheet.detents = [
            .mySmall(height: 120),
            .medium(),
            .myLarge()
        ]
        sheet.selectedDetentIdentifier = .mySmall
        sheet.largestUndimmedDetentIdentifier = .myLarge
        sheet.prefersGrabberVisible = true
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        return sheet
    }
}

extension ProximityVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
    }
}

// MARK: - MKMapViewDelegate
extension ProximityVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CustomPin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.canShowCallout = true
            
//            //         Add accessory button if needed
//            let detailButton = UIButton(type: .detailDisclosure)
//            view?.rightCalloutAccessoryView = detailButton
        } else {
            view?.annotation = annotation
        }
        if let imageAnnotation = annotation as? ImageAnnotation {
            view?.image = imageAnnotation.image
        }
        
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            centerMapOnCoordinate(annotation.coordinate)
        }
    }
}
