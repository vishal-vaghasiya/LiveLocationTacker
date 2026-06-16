//
//  OpenMapVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 03/09/25.
//

import UIKit
import MapKit
import SDWebImage

class OpenMapVC: UIViewController {
    
    // MARK: - Zoom Limits
    private let minSpan: CLLocationDegrees = 0.001
    private let maxSpan: CLLocationDegrees = 100
    
    // MARK: - OUTLET
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var addressTV: UITableView!
    @IBOutlet weak var conHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnSelectContinue: PrimaryButton!
    // MARK: - PROPERTY
    var currentMapType: MKMapType = .standard
    let locationManager = CLLocationManager()
    var onSaveContinueTapped: ((CLLocationCoordinate2D?, String) -> Void)?
    private var draggablePin: MKPointAnnotation?
    private let geocoder = CLGeocoder()
    var selectedCoordinate: CLLocationCoordinate2D?
    var address = String()
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNativeAd()
        if let savedCoordinate = selectedCoordinate {
            // 🟢 Existing data → show pin at saved location
            addDraggablePin(at: savedCoordinate)
            self.txtSearch.text = address
            self.btnClear.isHidden = address.count == 0
        } else {
            // 🟢 No existing data → show current location
            LocationManager.shared.fetchCurrentLocation { location in
                self.addDraggablePin(at: location.coordinate)
                self.fetchAddress(for: location.coordinate)
                let region = MKCoordinateRegion(center: location.coordinate,
                                                latitudinalMeters: 500,
                                                longitudinalMeters: 500)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLocalization()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        mapView.delegate = self
        mapView.showsUserLocation = false
        locationManager.startUpdatingLocation()
        
        addressTV.delegate = self
        addressTV.dataSource = self
        
        searchCompleter.delegate = self
        
        txtSearch.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
    
    func setupLocalization(){
        txtSearch.placeholder = L10n.searchLocation
        btnSelectContinue.setTitle(L10n.selectContinue, for: .normal)
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
                presented.dismiss(animated: true, completion: nil)
            }
        }
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
    
    @IBAction func selectAndContinueClick(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.onSaveContinueTapped?(self.selectedCoordinate, self.address)
        }
    }
    
    @IBAction func clearButtonClick(_ sender: UIButton) {
        clear()
    }
    
    // MARK: - OTHER
    func clear(){
        self.btnClear.isHidden = true
        self.txtSearch.text = ""
        self.address = ""
        self.selectedCoordinate = nil
        
        if let pin = draggablePin {
            mapView.removeAnnotation(pin)
        }
        
        searchResults.removeAll()
        addressTV.reloadData()
        txtSearch.resignFirstResponder()
    }
    // MARK: - API CALLING

    // MARK: - Draggable Pin Methods
    func addDraggablePin(at coordinate: CLLocationCoordinate2D) {
        if let pin = draggablePin {
            mapView.removeAnnotation(pin)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        //annotation.title = ""
        draggablePin = annotation
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: true)
    }

    private func fetchAddress(for coordinate: CLLocationCoordinate2D) {
        LocationManager.shared.getAddressFrom(latitude: coordinate.latitude, longitude: coordinate.longitude) { address in
            self.selectedCoordinate = coordinate
            self.address = address ?? ""
            self.txtSearch.text = address
            self.btnClear.isHidden = self.address.count == 0
        }
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        searchCompleter.queryFragment = textField.text ?? ""
        btnClear.isHidden = (textField.text ?? "").isEmpty
    }
}

extension OpenMapVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let identifier = "CustomDraggablePin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.isDraggable = true
            annotationView?.canShowCallout = true
            annotationView?.image = Asset.addressPin.image
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == .ending {
            if let coordinate = view.annotation?.coordinate {
                fetchAddress(for: coordinate)
            }
        }
    }
}

extension OpenMapVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let _ = presentationController.presentedViewController as? PopupMapSettings {
            // PopupMapSettings was dismissed
        }
    }
}

extension OpenMapVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        addressTV.isHidden = searchResults.isEmpty
        addressTV.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        addressTV.isHidden = true
    }
}

extension OpenMapVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completion = searchResults[indexPath.row]
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            guard let placemark = response?.mapItems.first?.placemark else { return }
            
            let coordinate = placemark.coordinate
            var addressParts: [String] = []

            if let title = placemark.title {
                addressParts.append(title)
            }
            
            let address = addressParts.joined(separator: ", ")
            
            // Call delegate
            self.selectedCoordinate = coordinate
            self.address = address
            self.txtSearch.text = address
            self.btnClear.isHidden = self.address.count == 0
            self.addressTV.isHidden = true
            
            self.addDraggablePin(at: coordinate)
            let region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)
            self.mapView.setRegion(region, animated: true)
        }

        self.txtSearch.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.conHeight.constant = self.addressTV.contentSize.height > 250 ? 250.0 : self.addressTV.contentSize.height
    }
}
