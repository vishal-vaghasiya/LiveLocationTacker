//
//  CircleVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 16/11/24.
//

import UIKit
import MapKit
import FirebaseDatabase
import Lottie

var selectedGroupsnapSort:DataSnapshot?

class CircleVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var lbl_circleName: UILabel!
    @IBOutlet weak var img_vectore: UIImageView!
    @IBOutlet weak var circle_view: UIView!
    @IBOutlet weak var map_view: MKMapView!
    @IBOutlet weak var bottom_view: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plus_lottieview: UIView!
    
    // MARK: - Properties
    let firebaseManager = FirebaseManager.shared
    let locationManager = CLLocationManager()
    var arrOfMember: [UserInfo] = []
    var groupSnapSortList = [DataSnapshot]()
    var currentMapType: MKMapType = .standard
    
    var locationPoints: [UserLocationModel] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllCircle()
        
        map_view.delegate = self
        map_view.showsUserLocation = false
        locationManager.startUpdatingLocation()
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        let animationView = LottieAnimationView(name: "Plus")
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.frame = plus_lottieview.bounds
        plus_lottieview.addSubview(animationView)
        animationView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.requestTrackingPermission { }
    }
    
    // MARK: - Firebase & API Methods
    func fetchAllCircle() {
//        firebaseManager.saveFcmTokenFirebase()
//        firebaseManager.fetchAllCircles(phoneNumber: DefaultManager.User.PHONE) { ListSnapSort in
//            DispatchQueue.main.async {
//                self.groupSnapSortList = ListSnapSort
//                selectedGroupsnapSort = ListSnapSort.first
//                self.lbl_circleName.text = selectedGroupsnapSort?.childSnapshot(forPath: "name").value as? String ?? ""
//                DefaultManager.Cirlce.CURRENT_CODE = selectedGroupsnapSort?.childSnapshot(forPath: "code").value as? String ?? ""
//                self.getMemberList()
//            }
//        }
        
        self.showLoader(text: "Loading...")
         firebaseManager.getMyCircle(completion: { success,message,snapshot  in
            self.hideLoader()
            if success {
                DispatchQueue.main.async {
                    self.groupSnapSortList = snapshot
                    selectedGroupsnapSort = snapshot.first
                    self.lbl_circleName.text = selectedGroupsnapSort?.childSnapshot(forPath: FirebaseKeys.name).value as? String ?? ""
                    self.getMemberList()
                }
            }
        })
    }
    
    func getMemberList(isHidLoader: Bool = false) {
        if !isHidLoader {
            self.showLoader(text: "Loading...")
        }
        DefaultManager.Cirlce.CURRENT_CODE = selectedGroupsnapSort?.childSnapshot(forPath: FirebaseKeys.code).value as? String ?? ""
        let membersPhone = selectedGroupsnapSort?.childSnapshot(forPath: FirebaseKeys.members).value as? [String:Any] ?? [:]
        if let phoneNumbers = Array(membersPhone.keys.sorted()) as? [String] {
            firebaseManager.fetchUsersData(phoneNumbers: phoneNumbers) { result in
                self.hideLoader()
                switch result {
                case .success(let users):
                    print("Fetched Users: \(users)")
                    self.arrOfMember = parseUsers(from: users)
                    self.tableView.reloadData()
                    self.addMemberPinsToMap()
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    self.arrOfMember.removeAll()
                    self.tableView.reloadData()
                    self.addMemberPinsToMap()
                }
            }
        } else {
            self.hideLoader()
            self.arrOfMember.removeAll()
            self.tableView.reloadData()
            self.addMemberPinsToMap()
        }
    }
    
//    func fetchMemberListFromCircle(){
//        let membersPhone = selectedGroupsnapSort?.childSnapshot(forPath: FirebaseKeys.members).value as? [String:Any] ?? [:]
//        if let phoneNumbers = Array(membersPhone.keys.sorted()) as? [String] {
//            print(phoneNumbers)
//            firebaseManager.fetchUsersData(phoneNumbers: phoneNumbers) { result in
//                switch result {
//                case .success(let users):
//                    print("Fetched Users: \(users)")
//                case .failure(let error):
//                    print("Error: \(error.localizedDescription)")
//                }
//            }
//        }
//        self.tableView.reloadData()
//        self.addMemberPinsToMap()
//    }
    
    @objc func batteryLevelDidChange() {
        let currentBatteryLevel = Int(UIDevice.current.batteryLevel * 100) // Convert to percentage
        firebaseManager.updateBatteryLevel(userPhone:  DefaultManager.User.PHONE , batteryLevel: currentBatteryLevel)
    }
    
    // MARK: - Button Actions
    @IBAction func btnPlusMemberAction(_ sender: UIButton) {
        let vc = StoryboardScene.Circle.joinCircleVC.instantiate()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSubscribeAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = StoryboardScene.Settings.subscribeVC.instantiate()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btnSelectGroupAction(_ sender: UIButton) {
        let vc = StoryboardScene.Circle.myCirclesPopup.instantiate()
        vc.groupSnapSortList = self.groupSnapSortList
        vc.joinCircle = {
            let vc = StoryboardScene.Circle.joinCircleVC.instantiate()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vc.selectedGroup = { (data) in
            self.groupSnapSortList = data
            self.lbl_circleName.text = selectedGroupsnapSort?.childSnapshot(forPath: FirebaseKeys.name).value as? String ?? ""
            self.getMemberList()
        }
        vc.updateCircle = { (data) in
            self.groupSnapSortList = data
            self.lbl_circleName.text = selectedGroupsnapSort?.childSnapshot(forPath: FirebaseKeys.name).value as? String ?? ""
            self.getMemberList(isHidLoader: true)
        }
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    @IBAction func btnMapTypeAction(_ sender: UIButton) {
        let vc = StoryboardScene.Circle.mapSettingsVC.instantiate()
        vc.selectedMapType = currentMapType
        vc.updateMap = { (mapType) in
            self.currentMapType = mapType
            self.map_view.mapType = self.currentMapType
        }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    @IBAction func btnGpsAction(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        LocationManager.shared.getCurrentLocation { location in
            let region = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)
            self.map_view.setRegion(region, animated: true)
        }
        /*
         guard let userLocation = map_view.userLocation.location else {
         print("User location not available.")
         return
         }
         let region = MKCoordinateRegion(center: userLocation.coordinate,
         latitudinalMeters: 500,
         longitudinalMeters: 500)
         map_view.setRegion(region, animated: true)
         */
    }
    
    @IBAction func btnSosAction(_ sender: UIButton) {
        if selectedGroupsnapSort != nil {
            let vc = StoryboardScene.Circle.sosVC.instantiate()
            vc.arrOfMember = self.arrOfMember
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    // MARK: - Map Methods
    func plotRoute() {
        // Only remove overlays (keep member pins/annotations as-is)
        map_view.removeOverlays(map_view.overlays)
        
        // Guard: need at least 2 points to draw a route.
        guard locationPoints.count >= 2 else {
            print("No route to draw — not enough coordinates.")
            return
        }
        
        // Draw directions-based route for each segment
        for i in 0..<locationPoints.count - 1 {
            let sourceCoord = CLLocationCoordinate2D(
                latitude: locationPoints[i].latitude,
                longitude: locationPoints[i].longitude
            )
            let destCoord = CLLocationCoordinate2D(
                latitude: locationPoints[i + 1].latitude,
                longitude: locationPoints[i + 1].longitude
            )
            
            let source = MKPlacemark(coordinate: sourceCoord)
            let destination = MKPlacemark(coordinate: destCoord)
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: source)
            request.destination = MKMapItem(placemark: destination)
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { [weak self] response, error in
                if let error = error {
                    print("❌ Failed to calculate route: \(error.localizedDescription)")
                    return
                }
                guard let route = response?.routes.first else { return }
                self?.map_view.addOverlay(route.polyline)
                // Don't reset region for every segment; let caller decide if/when to zoom.
            }
        }
    }
    
    func addMemberPinsToMap() {
        map_view.removeAnnotations(map_view.annotations)
        for member in self.arrOfMember {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: member.latitude, longitude: member.longitude)
            annotation.title = member.name
            annotation.subtitle = member.phone // Use phone number as the subtitle
            map_view.addAnnotation(annotation)
        }
    }
}

// MARK: - UITableView Delegate & DataSource

extension CircleVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfMember.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withType: MemberTBVCell.self)
        let data = self.arrOfMember[indexPath.row]
       
        cell.member_battery.text = "\(data.batteryLevel)%"
        cell.member_name.text = data.name
        cell.mrmber_image.setImage(urlString: data.profilePic, name: data.name, placeholderImage: Asset.iconDefaultProfile.image, width: cell.mrmber_image.frame.width * 2, height: cell.mrmber_image.frame.height * 2)
        
        LocationManager.shared.getGoogleAddress(lat: data.latitude, long: data.longitude) { address in
            DispatchQueue.main.async {
                cell.member_address.text = address
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.arrOfMember[indexPath.row]
        let coordinates = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
        map_view.setRegion(MKCoordinateRegion(center: coordinates, latitudinalMeters: 500,longitudinalMeters: 500),animated: true)
    }
}


// MARK: - MKMapViewDelegate

extension CircleVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "CustomPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "pin-map") // Replace with your custom pin image name
            annotationView?.bounds.size = CGSize(width: 50, height: 50)
            
            // Add accessory button if needed
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailButton
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            print("User location not available")
            return
        }
        
        let number = (annotation.subtitle ?? "") ?? ""
        if number.isEmpty { return }
        
        FirebaseManager.shared.fetchTodayLocations(for: number) { locations in
            self.locationPoints = locations.sorted { $0.timestamp < $1.timestamp }
            self.plotRoute()
            
            // Reselect the annotation after drawing route to keep callout open
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                mapView.selectAnnotation(annotation, animated: false)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else { return }
        let vc = StoryboardScene.Circle.userDeatilsVC.instantiate()
        vc.modalPresentationStyle = .overFullScreen
        LocationManager.shared.getAddressFromLatLon(latitude: annotation.coordinate.latitude,
                                                    longitude: annotation.coordinate.longitude) { address in
            vc.address = address ?? ""
            vc.username = (annotation.title ?? "") ?? ""
            vc.usernumber = (annotation.subtitle ?? "") ?? ""
            self.present(vc, animated: false)
        }
    }
    
    //FOR LINE
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
}
