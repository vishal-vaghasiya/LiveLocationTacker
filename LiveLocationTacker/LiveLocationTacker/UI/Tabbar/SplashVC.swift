//
//  SplashVC.swift
//
//  Created by DREAMWORLD on 13/09/24.
//

import UIKit
import ProgressHUD
import NVActivityIndicatorView
import GoogleMobileAds
class SplashVC: UIViewController {
    
    @IBOutlet weak var vwActivity: NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        showLoader()
        
        guard reachability.connection != .unavailable else {
            self.navigateToHome()
            return
        }
        
        VariableInfo.appDelegate.setupRemoteConfig {
            switch AdsConfig.startAdsPreference {
            case .yes:
                //Load Open Ads
                OpenAdsManager.shared.loadAndShow {
                    self.navigateToHome()
                }
            case .no:
                //Load Interstitial Ads
                InterstitialAdsManager.shared.loadAndShow {
                    self.navigateToHome()
                }
            case .none:
                // No Ads
                self.navigateToHome()
            }
        }
    }
    
    func showLoader() {
        vwActivity.type = .lineSpinFadeLoader
        vwActivity.padding = 4.0
        vwActivity.color = .button_color
        vwActivity.startAnimating()
    }
}
