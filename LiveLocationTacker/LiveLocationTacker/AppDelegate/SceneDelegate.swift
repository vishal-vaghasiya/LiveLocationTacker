//
//  SceneDelegate.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 29/10/24.
//

import UIKit
import AppTrackingTransparency
import RevenueCat
import AdSupport


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        window?.overrideUserInterfaceStyle = .light
        refreshUserDetails()
        
        if Constants.USERDEFAULTS.bool(forKey: "isIntro") == true {
            setupHome()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        checkforceUpdate()
        
//        if !Constants.userSubscribeAvailable && Constants.ads_visibility == "1" && Constants.Appopen_adsShow == "Yes" {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
//                AppOpenAdManager.shared.tryToPresentAd(viewController: (self.window?.rootViewController)!)
//            })
//        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}


//MARK: - Continue with Root -

extension SceneDelegate {
    
    func setupHome() {
        guard let frontViewController = Constants.tab_storyBoard.instantiateViewController(withIdentifier: "SplashVC") as? SplashVC else { return }
        let frontNavigationController = UINavigationController(rootViewController: frontViewController)
        frontNavigationController.isNavigationBarHidden = true
        window?.rootViewController = frontNavigationController
    }

    func checkforceUpdate(){
        DispatchQueue.main.async { [self] in
            let numberFormatter = NumberFormatter()
            let Force_update_version_number = numberFormatter.number(from: Constants.ios_version)
            let Force_update_versionFloatValue = Force_update_version_number?.floatValue
            let realseVersion = getAppInfo()
            if realseVersion < Force_update_versionFloatValue ?? 0 || Constants.force_update == "1" {
                DispatchQueue.main.async { [self] in
                    let vc = UpdateViewController()
                    window?.rootViewController = vc
                    window?.makeKeyAndVisible()
                }
            }
        }
    }
}


//MARK: - Validation Check -

extension SceneDelegate {
    
    func refreshUserDetails() {
        Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements[Constants.entitlementID]?.isActive == true {
                //Constants.USERDEFAULTS.set(true, forKey: "pro")
                DefaultManager.IS_SUBSCRIPTION = true
            } else {
                //Constants.USERDEFAULTS.removeObject(forKey: "pro")
                DefaultManager.IS_SUBSCRIPTION = false
            }
        }
    }
}


extension UIViewController {
    
    var onTapOtherButtonAction: ((UIButton) -> Void) {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onTapOtherButtonAction) as? ((UIButton) -> Void) ?? { _ in }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onTapOtherButtonAction, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private struct AssociatedKeys {
        static var onTapOtherButtonAction = "onTapOtherButtonAction"
    }
    
    
//    func callSplashApi(completion:@escaping()->()) {
//        ApiManager.shared.fetch(url: URL(string: Constants.SPLASH_API)!) { (result: Result<AdsDataModel, Error>) in
//            switch result {
//            case .success(let adsData):
//                print("Data fetched successfully: \(adsData)")
//                
//                Constants.NATIVE = adsData.nativeIDAds ?? ""
//                Constants.NATIVE2 = adsData.nativeIDOneAds ?? ""
//                
//                Constants.INTERTIALS = adsData.interstitialIDAds ?? ""
//                Constants.INTERTIALS2 = adsData.interstitialIDOneAds ?? ""
//                
//                Constants.BANNER = adsData.bannerIDAds ?? ""
//                Constants.BANNER2 =  adsData.bannerIDOneAds ?? ""
//                
//                Constants.OPEN = adsData.appOpenIDAds ?? ""
//                Constants.OPEN2 = adsData.appOpenIDOneAds ?? ""
//                
//                Constants.Splash_adsShow = adsData.splashAds ?? ""
//                Constants.Banner_adsShow = adsData.bannerAds ?? ""
//                Constants.Interstitial_adsShow = adsData.interstitialAds ?? ""
//                Constants.Appopen_adsShow = adsData.appOpenAds ?? ""
//                Constants.Native_adsShow = adsData.nativeAds ?? ""
//            
//                Constants.NATIVE_BUTTON_COLOR = adsData.nativeButtonAds ?? ""
//                Constants.ads_visibility = "1"
//                
//                Constants.Intro_Purchase_Ads = adsData.introPurchaseAds ?? ""
//                
//                Constants.firsttime_counter = adsData.interstitialCountAds ?? 1
//                Constants.ads_counter = adsData.interstitialCountShowAds ?? 3
//                
//                completion()
//            case .failure(let error):
//                print("Failed to fetch data: \(error.localizedDescription)")
//                completion()
//            }
//        }
//    }
    
    func setRightSideButtonInNavigationBar(visibleBtnCount: Int = 0,isSetText:Bool = false,secondFolderImageName:String = "ic_Settings",seconBtnFram:CGRect = CGRect(x: 0, y: 0, width: 30, height: 30),completion:((UIButton) -> Void)? = nil) {
        
//        let proButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//        let editButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//        
//        let proButton = UIButton(type: .custom)
//        proButton.frame = CGRect(x: 0,y: 0,width: 30,height: 30)
//        proButton.setBackgroundImage(UIImage(named: "ic_Pro"), for: .normal)
//        proButton.addTarget(self, action: #selector(didTapProButton), for: .touchUpInside)
//        proButtonView.addSubview(proButton)
//        
//        let editbutton = UIButton(type: .custom)
//        editbutton.frame = seconBtnFram
//        editbutton.setBackgroundImage(UIImage(named: secondFolderImageName), for: .normal)
//        editbutton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
//        editButtonView.addSubview(editbutton)
//        
//        let editNavButton = UIBarButtonItem(customView: editButtonView)
//        let proButtonItem = UIBarButtonItem(customView: proButtonView)
//        
//        // Add UIBarButtonItems to the navigation item
//        if visibleBtnCount == 1 {
//            self.navigationItem.rightBarButtonItem = Constants.userSubscribeAvailable ? nil : proButtonItem
//        }
//        else if visibleBtnCount == 2 {
//            self.navigationItem.rightBarButtonItem = editNavButton
//        }
//        else {
//            self.navigationItem.rightBarButtonItems = Constants.userSubscribeAvailable ? [editNavButton] : [proButtonItem,editNavButton]
//        }
        completion?(UIButton())
    }
    
    @objc private func didTapProButton(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            let vc = Constants.main_storyBoard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    @objc private func didTapEditButton(sender: UIButton) {
        onTapOtherButtonAction(sender)
    }
    
    func setNavigationTitleToLeft(title: String,textColor: UIColor = .white) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .black
        titleLabel.font = AppFont.medium(size: 22)
        titleLabel.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
//    func AppTrackingReuest(completion:@escaping()->()) {
//        if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                completion()
//            })
//        }
//    }
    
    func requestTrackingPermission(completion:@escaping()->()) {
        // Check if iOS 14.5 or later
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("Tracking authorized")
                    // You can now access the IDFA (Identifier for Advertisers)
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    print("IDFA: \(idfa)")
                    
                case .denied:
                    print("Tracking denied")
                    
                case .restricted:
                    print("Tracking restricted")
                    
                case .notDetermined:
                    print("Tracking permission not determined")
                    
                @unknown default:
                    print("Unknown status")
                }
                completion()
            }
        } 
        else {
            completion()
            print("ATT framework is not available. Default behavior applies.")
        }
    }
}
