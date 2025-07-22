//
//  PopupEnableChildmode.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 02/07/25.
//

import UIKit

class PopupEnableChildmode: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIView!
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBannerAds()
    }
    
    // MARK: - UI SETUP
    
    // MARK: - Setup Ads
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
    @IBAction func closeButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func disableClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .setting_childmode_click_diable)
        let vc = StoryboardScene.ChildMode.popupRequestToDisable.instantiate()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
