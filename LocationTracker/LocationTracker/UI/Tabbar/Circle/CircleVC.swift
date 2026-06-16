//
//  CircleVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 06/08/25.
//

import UIKit
import MapKit
import SDWebImage
class CircleVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnCircleName: UIButton!
    @IBOutlet weak var premiumButton: UIButton!
    
    // MARK: - Zoom Limits
    private let minSpan: CLLocationDegrees = 0.001
    private let maxSpan: CLLocationDegrees = 100
    
    // MARK: - PROPERTY
    var locationPoints: [UserLocationModel] = []
    let locationManager = CLLocationManager()
    var arrOfMember: [UserInfo] = []
    var arrOfCircle = [CircleInfo]()
    var currentMapType: MKMapType = .standard
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseManager.shared.isUserInAnyChildCircle()
        //self.premiumButton.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE || DefaultManager.IS_SUBSCRIPTION
        self.fetchAllCircle(isShowLoader: AppData.shared.selectedCircleInfo == nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissPresentedSheetIfNeeded()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        mapView.delegate = self
        mapView.showsUserLocation = false
        locationManager.startUpdatingLocation()
        FirebaseManager.shared.logAnalyticsEvent(name: .home_click_circle)
        
        /*if isComeFromLogin {
            after(2) {
                isComeFromLogin = false
                let vc = StoryboardScene.Circle.popupShareAppFirstTime.instantiate()
                vc.modalPresentationStyle = .overFullScreen
                vc.onDismissed = {
                    self.presentMemberList()
                }
                if let presented = self.presentedViewController {
                    presented.dismiss(animated: false) {
                        self.present(vc, animated: false)
                    }
                } else {
                    self.present(vc, animated: false)
                }
            }
        }*/
    }
    
    private func presentMemberList() {
        let memberVC = StoryboardScene.Circle.memberVC.instantiate()
        memberVC.arrOfMember = arrOfMember
        let nav = UINavigationController(rootViewController: memberVC)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.isModalInPresentation = true
        nav.navigationBar.isHidden = true
        memberVC.onAddMemberTapped = {
            FirebaseManager.shared.logAnalyticsEvent(name: .home_click_addmember)
            self.dismissPresentedSheetIfNeeded()
            /*if DefaultManager.IS_SUBSCRIPTION {*/
                //let vc = StoryboardScene.Circle.addMemberVC.instantiate()
                //vc.invitationCode = AppData.shared.selectedCircleInfo?.code ?? ""
                //vc.isAddToGroup = true
            AdManager.shared.showInterstitialAd(from: self) {
                let vc = StoryboardScene.Circle.joinCircleVC.instantiate()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            /*} else {
                if self.arrOfMember.count >= 2 {
                    let vc = StoryboardScene.Premium.premiumVC.instantiate()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                } else {
                    AdManager.shared.showInterstitialAd(from: self) {
                        //let vc = StoryboardScene.Circle.addMemberVC.instantiate()
                        let vc = StoryboardScene.Circle.joinCircleVC.instantiate()
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }*/
        }
        memberVC.onUserLocationTapped = { data in
            if DefaultManager.User.IS_CHILD_MODE_ENABLE && data.phone != DefaultManager.User.PHONE { return }
            let coordinates = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
            self.mapView.setRegion(MKCoordinateRegion(center: coordinates, latitudinalMeters: 500,longitudinalMeters: 500),animated: true)
        }
        present(nav, animated: true)
    }
    
    private func dismissPresentedSheetIfNeeded() {
        if let presented = self.presentedViewController {
            if presented is MemberVC || presented is PopupUserInfo || presented is PopupMapSettings {
                presented.dismiss(animated: true, completion: nil)
            } else if let presentedNV = self.presentedViewController as? UINavigationController {
                if presentedNV.viewControllers.first is MemberVC ||  presented is PopupUserInfo || presented is PopupMapSettings {
                    presentedNV.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func dismissPresentedMapSeetingsSheetIfNeeded() {
        if let presented = self.presentedViewController {
            if presented is PopupMapSettings {
                presented.dismiss(animated: true, completion: {
                    self.presentMemberList()
                })
            }
        }
    }
    
    private func presentUserInfo(latitude: Double, longitude: Double, phoneNumber: String) {
        let vc = StoryboardScene.Circle.popupUserInfo.instantiate()
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 300 })]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        vc.onDismissed = {
            self.presentMemberList()
        }
        LocationManager.shared.getAddressFrom(latitude: latitude,
                                              longitude: longitude) { address in
            let arrOfUserInfo = self.arrOfMember.filter { $0.phone == phoneNumber }
            if arrOfUserInfo.count != 0 {
                arrOfUserInfo[0].address = address ?? ""
                vc.userInfo = arrOfUserInfo[0]
                if let presented = self.presentedViewController {
                    presented.dismiss(animated: false) {
                        self.present(vc, animated: false)
                    }
                } else {
                    self.present(vc, animated: false)
                }
            }
        }
    }
    
    private func presentMapStyle() {
        let vc = StoryboardScene.Circle.popupMapSettings.instantiate()
        vc.selectedMapType = currentMapType
        vc.onMapSelectedTapped = { type in
            self.dismissPresentedSheetIfNeeded()
            self.presentMemberList()
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
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func sosButtonClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .home_click_sos)
        let vc = StoryboardScene.Circle.sosCallingVC.instantiate()
        vc.onDismissed = {
            self.presentMemberList()
        }
        vc.onSentEvent = { isSent in
            let vc = StoryboardScene.Circle.commonAlertPopup.instantiate()
            vc.selectedPopType = isSent ? .SOS_Sent_Successfully : .SOS_Not_Sent
            vc.clickYesEvent = {
                
            }
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false)
        }
        let nv = UINavigationController(rootViewController: vc)
        nv.navigationBar.isHidden = true
        nv.modalPresentationStyle = .overFullScreen
        if let presented = self.presentedViewController {
            presented.dismiss(animated: false) {
                self.present(nv, animated: true)
            }
        } else {
            self.present(nv, animated: true)
        }
    }
    
    @IBAction func mapStyleButtonClick(_ sender: UIButton) {
        presentMapStyle()
    }
    
    @IBAction func currentLocationClick(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        LocationManager.shared.fetchCurrentLocation { location in
            let region = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func changeCircleButtonClick(_ sender: UIButton) {
        self.openCircleListVC()
    }
    
    @IBAction func premiumButtonClick(_ sender: UIButton) {
        DispatchQueue.main.async {
            FirebaseManager.shared.logAnalyticsEvent(name: .home_click_premium)
            let vc = StoryboardScene.Premium.premiumVC.instantiate()
            vc.onDismissed = {
                self.presentMemberList()
            }
            let nv = UINavigationController(rootViewController: vc)
            nv.navigationBar.isHidden = true
            nv.modalPresentationStyle = .overFullScreen
            if let presented = self.presentedViewController {
                presented.dismiss(animated: false) {
                    rootController?.present(nv, animated: true)
                }
            } else {
                rootController?.present(nv, animated: true)
            }
        }
    }
    
    
    @IBAction func clickZoomIn(_ sender: UIButton) {
        var region = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        region.span.latitudeDelta = max(minSpan, min(maxSpan, region.span.latitudeDelta))
        region.span.longitudeDelta = max(minSpan, min(maxSpan, region.span.longitudeDelta))
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func clickZoomOut(_ sender: UIButton) {
        var region = mapView.region
        region.span.latitudeDelta *= 2.0
        region.span.longitudeDelta *= 2.0
        region.span.latitudeDelta = max(minSpan, min(maxSpan, region.span.latitudeDelta))
        region.span.longitudeDelta = max(minSpan, min(maxSpan, region.span.longitudeDelta))
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - OTHER
    
    func openCircleListVC() {
        let vc = StoryboardScene.Circle.popupCIrcleList.instantiate()
        vc.arrOfCircle = arrOfCircle
        vc.onClosedTapped = {
            self.presentMemberList()
        }
        vc.onJoinCircleTapped = {
            AdManager.shared.showInterstitialAd(from: self) {
//                let addVC = StoryboardScene.Circle.addMemberVC.instantiate()
                let addVC = StoryboardScene.Circle.joinCircleVC.instantiate()
                addVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(addVC, animated: true)
            }
        }
        vc.onChangeCircleTapped = { (data) in
            self.arrOfCircle = data
            self.btnCircleName.setTitle(AppData.shared.selectedCircleInfo?.name, for: .normal)
            self.getMemberList()
        }
        vc.clickCreateCircleEvent = {
            AdManager.shared.showInterstitialAd(from: self) {
                let createVC = StoryboardScene.Circle.createCircleVC.instantiate()
                createVC.backEvent = {
                    after(0.2) {
                        self.openCircleListVC()
                    }
                }
                createVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(createVC, animated: true)
            }
        }
        vc.onEditCircleTapped = { data in
            AdManager.shared.showInterstitialAd(from: self) {
                let createVC = StoryboardScene.Circle.createCircleVC.instantiate()
                createVC.isEdit = true
                createVC.circleInfo = data
                createVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(createVC, animated: true)
            }
        }
        vc.modalPresentationStyle = .overCurrentContext
        if let presented = self.presentedViewController {
            presented.dismiss(animated: false) {
                rootController?.present(vc, animated: false)
            }
        } else {
            rootController?.present(vc, animated: false)
        }
    }
    
    func openChildModeRequestPopup() {
        if DefaultManager.NotificationSettings.notificationType != 0 {
            var notificationType: NotificationType = .none
            if let typeValue = (DefaultManager.NotificationSettings.userInfo[AnyHashable("type")] as? String).flatMap(Int.init) ?? DefaultManager.NotificationSettings.userInfo[AnyHashable("type")] as? Int {
                notificationType = NotificationType(rawValue: typeValue) ?? .none
            }
            
            if notificationType == .disableChildMode {
                let userInfo = DefaultManager.NotificationSettings.userInfo
                //SHOW DISABLE POPUP
                let name = userInfo[AnyHashable(FirebaseKeys.name)] as? String ?? ""
                let code = userInfo[AnyHashable(FirebaseKeys.code)] as? String ?? ""
                let childNumber = userInfo[AnyHashable(FirebaseKeys.childNumber)] as? String ?? ""
                // Instantiate the view controller
                self.dismissPresentedSheetIfNeeded()
                let popupVC = StoryboardScene.Child.disableRequestPopupVC.instantiate()
                popupVC.userName = name
                popupVC.modalPresentationStyle = .overFullScreen
                self.present(popupVC, animated: false, completion:  {
                    DefaultManager.NotificationSettings.notificationType = 0
                })
                popupVC.disbleClickEvent = {
                    FirebaseManager.shared.removeToChildCircle(from: code, childPhone: childNumber) { isRemove, error in
                        if isRemove {
                            let successVC = StoryboardScene.Circle.commonAlertPopup.instantiate()
                            successVC.selectedPopType = .Child_Mode_Disabled
                            successVC.userName = name
                            successVC.clickYesEvent = {
                                self.presentMemberList()
                            }
                            successVC.clickCancelEvent = {
                                self.presentMemberList()
                            }
                            successVC.modalPresentationStyle = .overFullScreen
                            self.present(successVC, animated: false)
                        }
                    }
                }
                popupVC.rejectClickEvent = {
                    self.presentMemberList()
                }
            }
        }
    }
    
    // MARK: - API CALLING
    func fetchAllCircle(isShowLoader: Bool = true) {
        if isShowLoader {
            Loader.show("Loading...")
        }
        FirebaseManager.shared.fetchUserData() { result, message in
            switch result {
            case .success(let userData):
                let childCode = userData.childMode
                FirebaseManager.shared.getMyCircle(completion: { success,message,data  in
                    Loader.hide()
                    if success {
                        DispatchQueue.main.async {
                            self.arrOfCircle = data
                            if childCode.code == "" {
                                if AppData.shared.selectedCircleInfo == nil {
                                    AppData.shared.selectedCircleInfo = data.first
                                } else {
                                    let filteredList = self.arrOfCircle.filter { $0.code == AppData.shared.selectedCircleInfo?.code }
                                    if filteredList.count > 0 {
                                        AppData.shared.selectedCircleInfo = filteredList[0]
                                    }
                                }
                            } else {
                                let filteredList = self.arrOfCircle.filter { $0.code == childCode.code }
                                if filteredList.count > 0 {
                                    AppData.shared.selectedCircleInfo = filteredList[0]
                                } else {
                                    if AppData.shared.selectedCircleInfo == nil {
                                        AppData.shared.selectedCircleInfo = data.first
                                    } else {
                                        let filteredList = self.arrOfCircle.filter { $0.code == AppData.shared.selectedCircleInfo?.code }
                                        if filteredList.count > 0 {
                                            AppData.shared.selectedCircleInfo = filteredList[0]
                                        }
                                    }
                                }
                            }
                            self.btnCircleName.setTitle(AppData.shared.selectedCircleInfo?.name, for: .normal)
                            self.getMemberList(isHidLoader: AppData.shared.selectedCircleInfo?.name != "")
                            self.openChildModeRequestPopup()
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
            Loader.show("Loading...")
        }
        DefaultManager.Cirlce.CURRENT_CODE = AppData.shared.selectedCircleInfo?.code ?? ""
        if let phoneNumbers = AppData.shared.selectedCircleInfo?.members as? [String] {
            FirebaseManager.shared.fetchUsersData(phoneNumbers: phoneNumbers) { result in
                Loader.hide()
                switch result {
                case .success(let users):
                    self.arrOfMember = parseUsers(from: users)
                    self.addMemberPinsToMap()
                    self.presentMemberList()
                case .failure(_):
                    self.arrOfMember.removeAll()
                    self.addMemberPinsToMap()
                    self.presentMemberList()
                }
            }
        } else {
            Loader.hide()
            self.arrOfMember.removeAll()
            self.addMemberPinsToMap()
            self.presentMemberList()
        }
    }
    // MARK: - DELEGATE
}

extension CircleVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let sheet = TabSheetPresentationController(presentedViewController: presented, presenting: source)
        sheet.detents = [
            .mySmall(height: 80),
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

class TabSheetPresentationController: UISheetPresentationController {
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        // Resize to avoid covering tab bar
        if let tc = presentingViewController as? UITabBarController,
           let cv = containerView {
            cv.clipsToBounds = true
            var frame = cv.frame
            frame.size.height -= tc.tabBar.frame.height
            cv.frame = frame
        }
        
        // Apply corner radius to the top corners only
        DispatchQueue.main.async {
            self.presentedView?.layer.cornerRadius = 20
            self.presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.presentedView?.clipsToBounds = true
        }
    }
}

extension UISheetPresentationController.Detent.Identifier {
    static let mySmall = UISheetPresentationController.Detent.Identifier("mySmall")
    static let myLarge = UISheetPresentationController.Detent.Identifier("myLarge")
}

extension UISheetPresentationController.Detent {
    static func mySmall(height: CGFloat) -> UISheetPresentationController.Detent {
        return .custom(identifier: .mySmall) { _ in height }
    }

    static func myLarge() -> UISheetPresentationController.Detent {
        return .custom(identifier: .myLarge) { context in
            return context.maximumDetentValue - 0.1
        }
    }
}

extension CircleVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let vc = presentationController.presentedViewController as? PopupMapSettings {
            // PopupMapSettings was dismissed
            self.presentMemberList()
        }
    }
}

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
        let phone = (annotation.subtitle ?? "") ?? ""
        presentUserInfo(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, phoneNumber: phone)
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
    
    func plotRoute() {
        mapView.removeOverlays(mapView.overlays)
        
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
                self?.mapView.addOverlay(route.polyline)
            }
        }
    }
    
    func addMemberPinsToMap() {
        mapView.removeAnnotations(mapView.annotations)
        for member in self.arrOfMember {
            if DefaultManager.User.IS_CHILD_MODE_ENABLE && member.phone != DefaultManager.User.PHONE { continue }
            downloadImage(from: member.profilePic) { image in
                guard let image = image else { return }
                
                let resized = self.makeCircularImage(image: image,
                                                     size: CGSize(width: 50, height: 50),
                                                     borderWidth: 4,
                                                     borderColor: Asset.appMain.color)
                
                let coordinate = CLLocationCoordinate2D(latitude: member.latitude, longitude: member.longitude)
                let name = getFullName(firstName: member.firstName, lastName: member.lastName)
                let annotation = ImageAnnotation(coordinate: coordinate, title: name, subTitle: member.phone, image: resized)
                
                self.mapView.addAnnotation(annotation)
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
