//
//  MainSplashVC.swift
//
//  Created by DREAMWORLD on 21/09/24.
//

import UIKit
import NVActivityIndicatorView
import ProgressHUD
class MainSplashVC: UIViewController {
    
    @IBOutlet weak var vwActivity: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.requestTrackingPermission {
            guard reachability.connection != .unavailable else {
                self.navigateToOnboarding()
                return
            }
            
            VariableInfo.appDelegate.setupRemoteConfig {
                switch AdsConfig.startAdsPreference {
                case .yes:
                    //Load Open Ads
                    OpenAdsManager.shared.loadAndShow {
                        self.navigateToOnboarding()
                    }
                case .no:
                    //Load Interstitial Ads
                    InterstitialAdsManager.shared.loadAndShow {
                        self.navigateToOnboarding()
                    }
                case .none:
                    // No Ads
                    self.navigateToOnboarding()
                }
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
