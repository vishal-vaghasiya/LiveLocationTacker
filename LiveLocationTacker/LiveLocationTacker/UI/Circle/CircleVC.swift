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
import SDWebImage

var selectedCircleInfo: CircleInfo?

class CircleVC: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var lbl_circleName: UILabel!
    @IBOutlet weak var img_vectore: UIImageView!
    @IBOutlet weak var circle_view: UIView!
    @IBOutlet weak var map_view: MKMapView!
    @IBOutlet weak var bottom_view: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var premiumButtonView: UIView!
    @IBOutlet weak var plus_lottieview: UIView!
    @IBOutlet weak var btnPlusMember: UIButton!
    
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIView!
    
    // MARK: - Properties
    let firebaseManager = FirebaseManager.shared
    let locationManager = CLLocationManager()
    var arrOfMember: [UserInfo] = []
    var arrOfCircle = [CircleInfo]()
    var currentMapType: MKMapType = .standard
    
    var locationPoints: [UserLocationModel] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map_view.delegate = self
        map_view.showsUserLocation = false
        locationManager.startUpdatingLocation()
        FirebaseManager.shared.logAnalyticsEvent(name: .home_click_circle)
        self.setBannerAds()
        if isComeFromLogin {
            after(2) {
                isComeFromLogin = false
                let vc = StoryboardScene.Circle.popupShareAppFirstime.instantiate()
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.premiumButtonView.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE || DefaultManager.IS_SUBSCRIPTION
        self.btnPlusMember.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE
        self.plus_lottieview.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE
        self.fetchAllCircle(isShowLoader: selectedCircleInfo == nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupPlusButtonAnimation()
        self.requestTrackingPermission { }
    }
    
    // MARK: - Setup Ads
    func setupPlusButtonAnimation() {
        let animationView = LottieAnimationView(name: "Plus")
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.frame = plus_lottieview.bounds
        plus_lottieview.addSubview(animationView)
        animationView.play()
    }
    
    func setBannerAds() {
        AdManager.shared.loadBannerAd(in: self.bannerView, rootViewController: self) { isShow in
            if isShow {
                UIView.animate(withDuration: 0.5) {
                    self.contBannerHeight.constant = 50
                    self.view.layoutIfNeeded()
                }
            } else {
                self.contBannerHeight.constant = 0
            }
        }
    }
    
    // MARK: - Firebase & API Methods
    func fetchAllCircle(isShowLoader: Bool = true) {
        if isShowLoader {
            showLoader(text: "Loading...")
        }
        firebaseManager.fetchUserData() { result, message in
            switch result {
            case .success(let userData):
                let childCode = userData.childMode
                self.firebaseManager.getMyCircle(completion: { success,message,data  in
                    hideLoader()
                    if success {
                        DispatchQueue.main.async {
                            self.arrOfCircle = data
                            if childCode.code == "" {
                                if selectedCircleInfo == nil {
                                    selectedCircleInfo = data.first
                                } else {
                                    let filteredList = self.arrOfCircle.filter { $0.code == selectedCircleInfo?.code }
                                    if filteredList.count > 0 {
                                        selectedCircleInfo = filteredList[0]
                                    }
                                }
                            } else {
                                let filteredList = self.arrOfCircle.filter { $0.code == childCode.code }
                                if filteredList.count > 0 {
                                    selectedCircleInfo = filteredList[0]
                                } else {
                                    if selectedCircleInfo == nil {
                                        selectedCircleInfo = data.first
                                    } else {
                                        let filteredList = self.arrOfCircle.filter { $0.code == selectedCircleInfo?.code }
                                        if filteredList.count > 0 {
                                            selectedCircleInfo = filteredList[0]
                                        }
                                    }
                                }
                            }
                            self.lbl_circleName.text = selectedCircleInfo?.name ?? ""
                            self.getMemberList(isHidLoader: selectedCircleInfo?.name != "")
                        }
                    }
                })
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getMemberList(isHidLoader: Bool = false) {
        if !isHidLoader {
            showLoader(text: "Loading...")
        }
        DefaultManager.Cirlce.CURRENT_CODE = selectedCircleInfo?.code ?? ""
        if let phoneNumbers = selectedCircleInfo?.members as? [String] {
            firebaseManager.fetchUsersData(phoneNumbers: phoneNumbers) { result in
                hideLoader()
                switch result {
                case .success(let users):
                    self.arrOfMember = parseUsers(from: users)
                    self.tableView.reloadData()
                    self.addMemberPinsToMap()
                case .failure(_):
                    self.arrOfMember.removeAll()
                    self.tableView.reloadData()
                    self.addMemberPinsToMap()
                }
            }
        } else {
            hideLoader()
            self.arrOfMember.removeAll()
            self.tableView.reloadData()
            self.addMemberPinsToMap()
        }
    }
    
    // MARK: - Button Actions
    @IBAction func btnPlusMemberAction(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .home_click_addmember)
        if DefaultManager.IS_SUBSCRIPTION {
            let vc = StoryboardScene.Circle.joinCircleVC.instantiate()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if self.arrOfMember.count >= 2 {
                let vc = StoryboardScene.Settings.choosePlanVC.instantiate()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } else {
                AdManager.shared.showInterstitialAd(from: self) {
                    let vc = StoryboardScene.Circle.joinCircleVC.instantiate()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func btnSubscribeAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            FirebaseManager.shared.logAnalyticsEvent(name: .home_click_premium)
            let vc = StoryboardScene.Settings.choosePlanVC.instantiate()
            let nv = UINavigationController(rootViewController: vc)
            nv.navigationBar.isHidden = true
            nv.modalPresentationStyle = .overFullScreen
            self.present(nv, animated: true)
        }
    }
    
    @IBAction func btnSelectGroupAction(_ sender: UIButton) {
        let vc = StoryboardScene.Circle.myCirclesPopup.instantiate()
        vc.arrOfCircle = self.arrOfCircle
        vc.joinCircle = {
            AdManager.shared.showInterstitialAd(from: self) {
                let vc = StoryboardScene.Circle.joinCircleVC.instantiate()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        vc.selectedGroup = { (data) in
            self.arrOfCircle = data
            self.lbl_circleName.text = selectedCircleInfo?.name ?? ""
            self.getMemberList()
        }
        vc.updateCircle = { (data) in
            self.arrOfCircle = data
            self.lbl_circleName.text = selectedCircleInfo?.name ?? ""
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
        LocationManager.shared.fetchCurrentLocation { location in
            let region = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)
            self.map_view.setRegion(region, animated: true)
        }
    }
    
    @IBAction func btnSosAction(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .home_click_sos)
        if selectedCircleInfo != nil {
            let vc = StoryboardScene.Circle.sosVC.instantiate()
            vc.arrOfMember = self.arrOfMember
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    // MARK: - Map Methods
    func plotRoute() {
        map_view.removeOverlays(map_view.overlays)
        
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
            }
        }
    }
    
    func addMemberPinsToMap() {
        map_view.removeAnnotations(map_view.annotations)
        for member in self.arrOfMember {
            if DefaultManager.User.IS_CHILD_MODE_ENABLE && member.phone != DefaultManager.User.PHONE { continue }
            downloadImage(from: member.profilePic) { image in
                guard let image = image else { return }
                
                let resized = self.makeCircularImage(image: image,
                                                     size: CGSize(width: 50, height: 50),
                                                     borderWidth: 4,
                                                     borderColor: Asset.color00BDFF.color)
                
                let coordinate = CLLocationCoordinate2D(latitude: member.latitude, longitude: member.longitude)
                let annotation = ImageAnnotation(coordinate: coordinate, title: member.name, subTitle: member.phone, image: resized)
                
                self.map_view.addAnnotation(annotation)
            }
        }
    }
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        SDWebImageManager.shared.loadImage(
            with: url,
            options: .highPriority,
            progress: nil
        ) { image, data, error, cacheType, finished, imageURL in
            if let error = error {
                print("Image download failed: \(error)")
                completion(nil)
            } else {
                completion(image)
            }
        }
    }
    
    func makeCircularImage(image: UIImage, size: CGSize, borderWidth: CGFloat = 2, borderColor: UIColor = .white) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { _ in
            let path = UIBezierPath(ovalIn: rect)
            path.addClip()
            image.draw(in: rect)
            
            borderColor.setStroke()
            path.lineWidth = borderWidth
            path.stroke()
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
        
        cell.setUpBattery(batteryLevel: data.batteryLevel)
        cell.member_name.text = data.name
        cell.mrmber_image.setImage(urlString: data.profilePic, name: data.name, placeholderImage: Asset.iconDefaultProfile.image, width: cell.mrmber_image.frame.width * 2, height: cell.mrmber_image.frame.height * 2)
        
        LocationManager.shared.getAddressFrom(latitude: data.latitude, longitude: data.longitude) { address in
            DispatchQueue.main.async {
                cell.member_address.text = address
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.arrOfMember[indexPath.row]
        if DefaultManager.User.IS_CHILD_MODE_ENABLE && data.phone != DefaultManager.User.PHONE { return }
        let coordinates = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
        map_view.setRegion(MKCoordinateRegion(center: coordinates, latitudinalMeters: 500,longitudinalMeters: 500),animated: true)
    }
}


// MARK: - MKMapViewDelegate

extension CircleVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CustomPin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.canShowCallout = true
            
            //         Add accessory button if needed
            let detailButton = UIButton(type: .detailDisclosure)
            view?.rightCalloutAccessoryView = detailButton
        } else {
            view?.annotation = annotation
        }
        
        if let imageAnnotation = annotation as? ImageAnnotation {
            view?.image = imageAnnotation.image
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            print("User location not available")
            return
        }
        let number = (annotation.subtitle ?? "") ?? ""
        if number.isEmpty { return }
        FirebaseManager.shared.fetchTodayUserLocations(for: number) { locations in
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
        LocationManager.shared.getAddressFrom(latitude: annotation.coordinate.latitude,
                                              longitude: annotation.coordinate.longitude) { address in
            let phone = (annotation.subtitle ?? "") ?? ""
            let arrOfUserInfo = self.arrOfMember.filter { $0.phone == phone }
            if arrOfUserInfo.count != 0 {
                arrOfUserInfo[0].address = address ?? ""
                vc.userInfo = arrOfUserInfo[0]
                self.present(vc, animated: false)
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

class ImageAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subTitle: String?, image: UIImage) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subTitle
        self.image = image
    }
}
