//
//  InterstitialAdsManager.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 16/07/25.
//

import GoogleMobileAds
import UIKit

final class InterstitialAdsManager: NSObject, FullScreenContentDelegate {
    
    static let shared = InterstitialAdsManager()
    
    private var interstitialAd: InterstitialAd?
    private var onComplete: (() -> Void)?
    var interstitialCurrentScreenCount: Int = 0
    
    func resetErrorCount() {
        AdsConfig.currentInterstitialCountErrorsAds = 0
    }
    
    private func incrementErrorCount() {
        AdsConfig.currentInterstitialCountErrorsAds += 1
    }
    
    private func errorCountExceeded() -> Bool {
        return AdsConfig.currentInterstitialCountErrorsAds >= AdsConfig.InterstitialCountErrorsAds
    }
    
    func loadAndShow(completion: @escaping () -> Void) {
        self.onComplete = completion
        
        if DefaultManager.IS_SUBSCRIPTION {
            completion()
            return
        }
        
        // ✅ If already loaded, show immediately
        if let ad = interstitialAd {
            print("[InterstitialAd] already loaded — presenting directly.")
            ad.present(from: rootController)
            return
        }
        
        // ❌ If ad not loaded, try loading
        guard !errorCountExceeded() else {
            print("[InterstitialAd] ⚠️ Max retries exceeded — not loading or showing.")
            completion()
            return
        }
        
        let request = Request()
        InterstitialAd.load(
            with: AdsConfig.InterstitialAdId,
            request: request
        ) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("[InterstitialAd] Failed to load: \(error.localizedDescription)")
                self.incrementErrorCount()
                self.onComplete?()
                return
            }
            
            // Success — reset error count
            self.resetErrorCount()
            
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            ad?.present(from: rootController)
            
        }
    }
    
    /// Load the interstitial ad
    func loadAd() {
        guard !errorCountExceeded() else {
            print("[InterstitialAd] ⚠️ Max error attempts reached — not loading.")
            return
        }
        
        if DefaultManager.IS_SUBSCRIPTION || AdsConfig.interstitialAdsPreference != .yes {
            return
        }
        
        // Avoid loading if already loaded
        guard interstitialAd == nil else { return }
        
        let request = Request()
        InterstitialAd.load(with: AdsConfig.InterstitialAdId, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("[InterstitialAd] Failed to load: \(error.localizedDescription)")
                self.incrementErrorCount()
                return
            }
            
            self.resetErrorCount()
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            print("[InterstitialAd] loaded and ready.")
        }
    }
    
    /// Show the ad if available, then run completion
    func showAd(from viewController: UIViewController, completion: @escaping () -> Void) {
        guard let ad = interstitialAd else {
            print("[InterstitialAd] not ready — skipping")
            loadAd() // Try to load for next time
            completion()
            return
        }
        
        if DefaultManager.IS_SUBSCRIPTION || AdsConfig.interstitialAdsPreference != .yes {
            completion()
            return
        }
        
        if interstitialCurrentScreenCount >= AdsConfig.InterstitialCountAds {
            interstitialCurrentScreenCount = 1
            // Success — reset error count
            self.resetErrorCount()
            self.onComplete = completion
            ad.present(from: viewController)
        } else {
            interstitialCurrentScreenCount += 1
            completion()
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[InterstitialAd] Dismissed")
        interstitialAd = nil
        loadAd()
        onComplete?()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[InterstitialAd] Failed to present: \(error.localizedDescription)")
        interstitialAd = nil
        loadAd()
        onComplete?()
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[InterstitialAd] Will present")
    }
}
