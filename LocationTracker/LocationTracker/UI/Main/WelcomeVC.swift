//
//  WelcomeVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit

class WelcomeVC: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnStart: PrimaryButton!
    @IBOutlet weak var continueButton: PrimaryButton!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setBannerAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    // MARK: - UI SETUP
    
    func setupLocalization() {
        self.lblTitle.text = L10n.welcome + " !"
        self.lblDescription.text = L10n.trackFamilyLocation
        self.btnStart.setTitle(L10n.getStarted, for: .normal)
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
    
    // MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func continueButtonClick(_ sender: PrimaryButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .welcome_click_start)
        AdManager.shared.showInterstitialAd(from: self) {
            let vc = StoryboardScene.Main.selectLanguageVC.instantiate()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
