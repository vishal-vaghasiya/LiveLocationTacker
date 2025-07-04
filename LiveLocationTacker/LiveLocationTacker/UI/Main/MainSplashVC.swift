//
//  MainSplashVC.swift
//
//  Created by DREAMWORLD on 21/09/24.
//

import UIKit
import NVActivityIndicatorView
import ProgressHUD
//import GoogleMobileAds


class MainSplashVC: UIViewController {

    @IBOutlet weak var vwActivity: NVActivityIndicatorView!
//    var appOpenAd: GADAppOpenAd?
//    var loadTime = Date()
    var isFirstAdsFailed = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showLoader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.requestTrackingPermission {
                
                guard reachability.connection != .unavailable else {
                    self.navigateToOnboarding()
                    return
                }
                        
                self.navigateToOnboarding()
                
//                self.callSplashApi {
//                    if Constants.ads_visibility == "1" && !Constants.userSubscribeAvailable && Constants.OPEN.isEmpty == false && Constants.Splash_adsShow == "Yes" {
//                        self.requestAppOpenAd(openID: Constants.OPEN)
//                    }
//                    else{
//                        self.navigateToOnboarding()
//                    }
//                }
            }
        }
    }
    
    func showLoader() {
        self.vwActivity.type = .lineSpinFadeLoader
        self.vwActivity.padding = 4.0
        self.vwActivity.color = .button_color
        self.vwActivity.startAnimating()
    }
}



//extension MainSplashVC : GADFullScreenContentDelegate {
//    
//    func requestAppOpenAd(openID: String) {
//        let request = GADRequest()
//        GADAppOpenAd.load(withAdUnitID:openID,request: request,completionHandler: { [self] (appOpenAdIn, error) in
//            if let error = error {
//                print("Failed to load Appopen ads with error: \(error.localizedDescription)")
//                if isFirstAdsFailed == false {
//                    requestAppOpenAd(openID: Constants.OPEN2)
//                    isFirstAdsFailed = true
//                }
//                else{
//                    self.navigateToOnboarding()
//                }
//                return
//            }
//            self.appOpenAd = appOpenAdIn
//            self.appOpenAd?.fullScreenContentDelegate = self
//            self.loadTime = Date()
//            self.tryToPresentAd(openID: Constants.OPEN)
//        })
//    }
//    
//    func tryToPresentAd(openID: String) {
//        if let gOpenAd = self.appOpenAd, let rwc = Constants.ROOTVIEW, wasLoadTimeLessThanNHoursAgo(thresholdN: 4) {
//            gOpenAd.present(fromRootViewController: rwc)
//        }
//        else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                self.requestAppOpenAd(openID: openID)
//            })
//        }
//    }
//    
//    func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
//        let now = Date()
//        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
//        let secondsPerHour = 3600.0
//        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
//        return intervalInHours < Double(thresholdN)
//    }
//    
//    //MARK: -- AppOpen delegate --
//
//    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
//        print("[OPEN AD] Failed: \(error)")
//        self.navigateToOnboarding()
//    }
//    
//    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("[OPEN AD] Ad dismissed")
//        self.navigateToOnboarding()
//    }
//    
//    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("[OPEN AD] Ad Will present")
//    }
//}
