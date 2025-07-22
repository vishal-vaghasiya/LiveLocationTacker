//
//  BannerAdsManager.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 17/07/25.
//

import GoogleMobileAds
import UIKit
final class BannerAdsManager: NSObject {
    
    static let shared = BannerAdsManager()
    
    private var bannerView: BannerView?
    private var onComplete: ((Bool) -> Void)?
    
    func resetErrorCount() {
        AdsConfig.currentBannerCountErrorsAds = 0
    }
    
    private func incrementErrorCount() {
        AdsConfig.currentBannerCountErrorsAds += 1
    }
    
    private func errorCountExceeded() -> Bool {
        return AdsConfig.currentBannerCountErrorsAds >= AdsConfig.BannerCountErrorsAds
    }
    
    func loadBannerAd(in containerView: UIView,
                      vc: UIViewController,
                      completion: @escaping (Bool) -> Void) {
        
        if DefaultManager.IS_SUBSCRIPTION || AdsConfig.bannerAdsPreference != .yes {
            completion(false)
            return
        }
        
        // ❌ If ad not loaded, try loading
        guard !BannerAdsManager.shared.errorCountExceeded() else {
            print("[BannerAd] ⚠️ Max retries exceeded — not loading or showing.")
            completion(false)
            return
        }
        
        let adSize = AdSize(size: CGSize(width: 320, height: 50), flags: 0) // ✅ Correct usage
        
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = AdsConfig.BannerAdId
        banner.rootViewController = vc
        banner.delegate = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(banner)
        containerView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            banner.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
            banner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        banner.load(Request())
        bannerView = banner
        self.onComplete = completion
    }
}

extension BannerAdsManager: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("[BannerAd] loaded.")
        self.resetErrorCount()
        onComplete?(true)
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("[BannerAd] Failed to load: \(error.localizedDescription)")
        self.incrementErrorCount()
        onComplete?(false)
    }
}
