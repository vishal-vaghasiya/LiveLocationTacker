//
//  SplashVC.swift
//  ScreenMirroring
//
//  Created by DREAMWORLD on 13/09/24.
//

import UIKit
import ProgressHUD
//import GoogleMobileAds
import NVActivityIndicatorView



class SplashVC: UIViewController {
    
    
    @IBOutlet weak var vwActivity: NVActivityIndicatorView!
    
//    var appOpenAd: GADAppOpenAd?
//    var loadTime = Date()
    var isFirstAdsFailed = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Call splash")
        showLoader()
        
        if Constants.USERDEFAULTS.bool(forKey: "pro") == true {
            Constants.userSubscribeAvailable = true
        }
        else{
            Constants.userSubscribeAvailable = false
        }
        
        guard reachability.connection != .unavailable else {
            self.navigateToHome()
            return
        }
        
        self.navigateToHome()
        
//        self.callSplashApi {
//            if Constants.ads_visibility == "1" && !Constants.userSubscribeAvailable && Constants.OPEN.isEmpty == false && Constants.Splash_adsShow == "Yes" {
//                self.requestAppOpenAd(openID: Constants.OPEN)
//            }
//            else{
//                self.navigateToHome()
//            }
//        }
    }
    
    func showLoader() {
        vwActivity.type = .lineSpinFadeLoader
        vwActivity.padding = 4.0
        vwActivity.color = .button_color
        vwActivity.startAnimating()
    }
}


//extension SplashVC : GADFullScreenContentDelegate {
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
//                    self.navigateToHome()
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
//            ProgressHUD.dismiss()
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
//        print("[OPEN AD] didFailToPresentFullScreenContentWithError: \(error)")
//        self.navigateToHome()
//    }
//    
//    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("[OPEN AD] Ad dismissed")
//        self.navigateToHome()
//    }
//    
//    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("[OPEN AD] Ad Will present")
//    }
//}
