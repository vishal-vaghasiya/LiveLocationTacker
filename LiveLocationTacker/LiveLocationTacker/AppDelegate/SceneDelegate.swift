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
        if DefaultManager.IS_INITIAL_SETUP {
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
        let vc = StoryboardScene.TabBar.splashVC.instantiate()
        let nv = UINavigationController(rootViewController: vc)
        nv.isNavigationBarHidden = true
        window?.rootViewController = nv
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
