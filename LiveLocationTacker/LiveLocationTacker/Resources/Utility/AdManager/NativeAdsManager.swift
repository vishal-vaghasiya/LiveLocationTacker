//
//  NativeAdsManager.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 17/07/25.
//

import GoogleMobileAds
import UIKit

final class NativeAdsManager: NSObject {
    
    static let shared = NativeAdsManager()
    
    // For handling individual ad requests
    private var adCompletionHandlers: [AdLoader: (NativeAd?) -> Void] = [:]
    private var cachedAds: [NativeAd] = []
    private let maxCacheSize = 3
    private var activeLoaders: [AdLoader] = []
    
    private override init() {
        super.init()
    }
    
    func resetErrorCount() {
        AdsConfig.currentNativeCountErrorsAds = 0
    }
    
    private func incrementErrorCount() {
        AdsConfig.currentNativeCountErrorsAds += 1
    }
    
    private func errorCountExceeded() -> Bool {
        return AdsConfig.currentNativeCountErrorsAds >= AdsConfig.NativeCountErrorsAds
    }
    
    // MARK: - Preload Ads
    func preloadAds(count: Int = 1) {
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                self.loadAd()
            }
        }
    }
    
    // MARK: - Get Ad (Cached or Load On Demand)
    func getAd(completion: @escaping (NativeAd?) -> Void) {
        if let ad = cachedAds.first {
            cachedAds.removeFirst()
            completion(ad)
            // Start preloading again to maintain cache size
            loadAd()
        } else {
            // No cached ad → Load now
            loadAd { ad in
                completion(ad)
            }
        }
    }
    
    // MARK: - Internal Ad Loader
    private func loadAd(completion: ((NativeAd?) -> Void)? = nil) {
        guard !errorCountExceeded() else {
            print("[NativeAd] ⚠️ Max error attempts reached — not loading.")
            return
        }
        
        if DefaultManager.IS_SUBSCRIPTION {
            completion?(nil)
            return
        }
        
        let adLoader = AdLoader(adUnitID: AdsConfig.NativeAdId,
                                rootViewController: nil,
                                adTypes: [.native],
                                options: nil)
        if let completion = completion {
            adCompletionHandlers[adLoader] = completion
        }
        adLoader.delegate = self
        activeLoaders.append(adLoader)
        adLoader.load(Request())
    }
    
}

// MARK: - GADNativeAdLoaderDelegate
extension NativeAdsManager: NativeAdLoaderDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        activeLoaders.removeAll { $0 === adLoader }
        print("[NativeAd] loaded.")
        self.resetErrorCount()
        if let completion = adCompletionHandlers[adLoader] {
            // On-demand load → Call completion
            completion(nativeAd)
            adCompletionHandlers.removeValue(forKey: adLoader)
        } else {
            // Preloaded → Cache it
            if cachedAds.count < maxCacheSize {
                cachedAds.append(nativeAd)
                print("Cached Ads Count: \(NativeAdsManager.shared.cachedAds.count)")
            }
        }
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        activeLoaders.removeAll { $0 === adLoader }
        print("[NativeAd] Debug Info: AdUnitID: \(AdsConfig.NativeAdId), Error: \(error)")
        self.incrementErrorCount()
        if let completion = adCompletionHandlers[adLoader] {
            completion(nil)
            adCompletionHandlers.removeValue(forKey: adLoader)
        }
    }
}

/*
class ViewController: UIViewController {
    
    @IBOutlet weak var nativeAdContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AdManager.shared.loadNativeAd { [weak self] ad in
            guard let self = self else { return }
            if let ad = ad {
                DispatchQueue.main.async {
                    self.displayNativeAd(ad)
                }
            } else {
                print("⚠️ No ad available")
            }
        }
    }
    
    private func displayNativeAd(_ nativeAd: NativeAd) {
        // Load the custom XIB
        guard let adView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first as? NativeAdView else {
            return
        }
        
        // Set frame to match container
        adView.frame = nativeAdContainer.bounds
        nativeAdContainer.addSubview(adView)
        
        // Assign the nativeAd to GADNativeAdView
        adView.nativeAd = nativeAd
        
        // Bind assets
        adView.headlineLabel.text = nativeAd.headline
        adView.bodyLabel.text = nativeAd.body
        adView.callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
        adView.adMediaView.mediaContent = nativeAd.mediaContent
        
        adView.callToActionButton.isUserInteractionEnabled = false // Required
    }
}
*/
/*
import GoogleMobileAds

class NativeAdView: NativeAdView {
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var adMediaView: MediaView!
    @IBOutlet weak var callToActionButton: UIButton!
}
*/
