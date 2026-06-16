//
//  SplashScreenVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//

import UIKit

class SplashScreenVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        AdManager.shared.requestAppTrackingPermission { }
        setBannerAds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ReachabilityManager.shared.isConnectedToNetwork() else {
            showToast(message: "No internet connection")
            self.navigateScreen()
            return
        }
        
        VariableInfo.appDelegate.setupRemoteConfig {
            switch AdsConfig.startAdsPreference {
            case .yes:
                //Load Open Ads
                OpenAdsManager.shared.loadAndShow {
                    self.navigateScreen()
                }
            case .no:
                //Load Interstitial Ads
                InterstitialAdsManager.shared.loadAndShow {
                    self.navigateScreen()
                }
            case .none:
                // No Ads
                self.navigateScreen()
            }
        }
    }
    
    // MARK: - UI SETUP
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
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
   private func navigateScreen(){
        if DefaultManager.IS_INITIAL_SETUP {
            goToDashboard()
        } else {
            goToWelcome()
        }
    }
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
