//
//  MapVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 16/11/24.
//

import UIKit
import MapKit
import FirebaseDatabase
import Lottie


var selectedGroupsnapSort:DataSnapshot?


class MapVC: UIViewController {

    @IBOutlet weak var lbl_circleName: UILabel!
    @IBOutlet weak var img_vectore: UIImageView!
    @IBOutlet weak var circle_view: UIView!
    @IBOutlet weak var map_view: MKMapView!
    @IBOutlet weak var bottom_view: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plus_lottieview: UIView!
    
    let groupManager = FirebaseManager()
    let locationManager = CLLocationManager()
    var memberList:[String:Any] = [:]
    var groupSnapSortList = [DataSnapshot]()
    var currentMapType: MKMapType = .standard
    
    var locationPoints: [UserLocationModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        bottom_view.makeTopCornerRound(20)
        circle_view.addShadow()
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
    
//    func plotRoute() {
//        let coordinates = locationPoints.map {
//            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
//        }
//
//        for coordinate in coordinates {
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            map_view.addAnnotation(annotation)
//        }
//
//        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
//        map_view.addOverlay(polyline)
//
//        if let first = coordinates.first {
//            map_view.setRegion(MKCoordinateRegion(center: first, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
//        }
//    }
    
    func plotRoute() {
        // Only remove overlays (keep member pins/annotations as-is)
        map_view.removeOverlays(map_view.overlays)

        // Don't addMemberPinsToMap() here; pins are handled elsewhere.

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
    
    @IBAction func btnPlusMemberAction(_ sender: UIButton) {
        let vc = StoryboardScene.TabBar.joinCircleVC.instantiate()
        vc.groupCode = selectedGroupsnapSort?.childSnapshot(forPath: "code").value as? String ?? ""
        //vc.groupFcmtoken = selectedGroupsnapSort?.childSnapshot(forPath: "fcmtoken").value as? String ?? ""
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSubscribeAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = Constants.main_storyBoard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btnSelectGroupAction(_ sender: UIButton) {
        //UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        //img_vectore.isHighlighted = !img_vectore.isHighlighted
        let vc = StoryboardScene.TabBar.myCirclesPopup.instantiate()
        vc.groupSnapSortList = self.groupSnapSortList
        vc.joinCircle = {
            let vc = StoryboardScene.TabBar.joinCircleVC.instantiate()
            vc.groupCode = selectedGroupsnapSort?.childSnapshot(forPath: "code").value as? String ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vc.selectedGroup = { (data) in
            self.groupSnapSortList = data
            self.memberList = selectedGroupsnapSort?.childSnapshot(forPath: "members").value as? [String:Any] ?? [:]
            self.lbl_circleName.text = selectedGroupsnapSort?.childSnapshot(forPath: "name").value as? String ?? ""
            self.addMemberPinsToMap()
        }
        vc.updateCircle = { (data) in
            self.groupSnapSortList = data
            self.lbl_circleName.text = selectedGroupsnapSort?.childSnapshot(forPath: "name").value as? String ?? ""
            self.getMemberList()
        }
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    @IBAction func btnMapTypeAction(_ sender: UIButton) {
        //UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let vc = StoryboardScene.TabBar.mapSettingsVC.instantiate()
        vc.selectedMapType = currentMapType
        vc.updateMap = { (mapType) in
            self.currentMapType = mapType
            self.map_view.mapType = self.currentMapType
        }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
        
//        switch currentMapType {
//        case .standard:
//            currentMapType = .satellite
//        case .satellite:
//            currentMapType = .hybrid
//        case .hybrid:
//            currentMapType = .standard
//        default:
//            currentMapType = .standard
//        }
//        map_view.mapType = currentMapType
    }
    
    @IBAction func btnGpsAction(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        guard let userLocation = map_view.userLocation.location else {
            print("User location not available.")
            return
        }
        let region = MKCoordinateRegion(center: userLocation.coordinate,
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500)
        map_view.setRegion(region, animated: true)
    }
    
    @IBAction func btnSosAction(_ sender: UIButton) {
        if selectedGroupsnapSort != nil {
            let vc = Constants.tab_storyBoard.instantiateViewController(withIdentifier: "SosVC") as! SosVC
            vc.modalPresentationStyle = .overFullScreen
            vc.memberList = memberList
            self.present(vc, animated: true)
        }
    }
    
    func fetchAllCircle() {
        groupManager.saveFcmTokenFirebase()
        groupManager.fetchAllCircles(phoneNumber: Constants.USERDEFAULTS.getCurrentuserNumber()) { ListSnapSort in
            DispatchQueue.main.async {
                self.groupSnapSortList = ListSnapSort
                selectedGroupsnapSort = ListSnapSort.first
                self.lbl_circleName.text = selectedGroupsnapSort?.childSnapshot(forPath: "name").value as? String ?? ""
                self.getMemberList()
            }
        }
    }
    
    func getMemberList(){
        self.fetchMemberListFromCircle()
    }
    
    func fetchMemberListFromCircle(){
        self.memberList = selectedGroupsnapSort?.childSnapshot(forPath: "members").value as? [String:Any] ?? [:]
        self.tableView.reloadData()
        self.addMemberPinsToMap()
    }
    
    @objc func batteryLevelDidChange() {
        let currentBatteryLevel = Int(UIDevice.current.batteryLevel * 100) // Convert to percentage
        groupManager.updateBatteryLevel(userPhone:  Constants.USERDEFAULTS.getCurrentuserNumber() , batteryLevel: currentBatteryLevel)
    }
}


//MARK: - Datasource

extension MapVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withType: MemberTBVCell.self)
        if let memberKeys = Array(memberList.keys.sorted()) as? [String],
           let memberDicvalue = memberList[memberKeys[indexPath.row]]  as? [String:Any] {
            
            cell.member_battery.text = "\(memberDicvalue["batteryLevel"] as? Int ?? 0)%"
            cell.member_name.text = memberDicvalue["username"] as? String ?? ""
            
            LocationManager.shared.getGoogleAddress(lat: memberDicvalue["latitude"] as? Double ?? 0, long: memberDicvalue["longitude"] as? Double ?? 0) { address in
                DispatchQueue.main.async {
                    cell.member_address.text = address
                }
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let memberKeys = Array(memberList.keys.sorted()) as? [String],
           let memberDicvalue = memberList[memberKeys[indexPath.row]]  as? [String:Any] {
            
            let coordinates = CLLocationCoordinate2D(latitude: memberDicvalue["latitude"] as? Double ?? 0, longitude: memberDicvalue["longitude"] as? Double ?? 0)
            map_view.setRegion(MKCoordinateRegion(center: coordinates, latitudinalMeters: 500,longitudinalMeters: 500),animated: true)
        }
    }
}


extension MapVC : MKMapViewDelegate {
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

        FirebaseManager().fetchTodayLocations(for: number) { locations in
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
        let vc = Constants.tab_storyBoard.instantiateViewController(withIdentifier: "UserDeatilsVC") as! UserDeatilsVC
        vc.modalPresentationStyle = .overFullScreen
        LocationManager.shared.getAddressFromLatLon(latitude: annotation.coordinate.latitude,
                                                    longitude: annotation.coordinate.longitude) { address in
            vc.address = address ?? ""
            vc.username = (annotation.title ?? "") ?? ""
            vc.usernumber = (annotation.subtitle ?? "") ?? ""
            self.present(vc, animated: false)
        }
    }
    
    func addMemberPinsToMap() {
        map_view.removeAnnotations(map_view.annotations) // Remove any existing annotations
        for (_, member) in memberList {
            if let memberData = member as? [String: Any],
               let latitude = memberData["latitude"] as? Double,
               let longitude = memberData["longitude"] as? Double,
               let username = memberData["username"] as? String,
               let userPhone = memberData["userPhone"] as? String { // Get phone number
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = username
                annotation.subtitle = userPhone // Use phone number as the subtitle
                map_view.addAnnotation(annotation)
            }
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
