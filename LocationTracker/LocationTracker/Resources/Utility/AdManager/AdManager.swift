//
//  AdManager.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//

import Foundation
import UIKit

// MARK: - AdsConfig
struct AdsConfig {
    
    static var startAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var appOpenAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var bannerAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var interstitialAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var nativeAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var nativeAdsPreLoadPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    // OPEN ADS
    static var AppOpenAdId: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    // BANNER ADS
    static var BannerAdId: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var BannerCountErrorsAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var currentBannerCountErrorsAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    // INTRSTITIAL ADS
    static var InterstitialAdId: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var InterstitialCountAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var InterstitialCountErrorsAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var currentInterstitialCountErrorsAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var InterstitialCountShowAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    // NATIVE ADS
    static var NativeAdId: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var NativeCountErrorsAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var currentNativeCountErrorsAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
}

import GoogleMobileAds
import AppTrackingTransparency

class AdManager: NSObject {
    
    static let shared = AdManager()
    
    private var nativeAdLoader: AdLoader?
    private var nativeAdView: NativeAdView?
    
    private override init() {
        super.init()
    }

    func resetErrorCount() {
        BannerAdsManager.shared.resetErrorCount()
        InterstitialAdsManager.shared.resetErrorCount()
        NativeAdsManager.shared.resetErrorCount()
    }
    
    func requestAppTrackingPermission(completion: @escaping () -> Void) {
        ATTrackingManager.requestTrackingAuthorization { _ in
            completion()
        }
    }
    
    // MARK: - App Open Ad
    func tryToPresentAd() {
        OpenAdsManager.shared.tryToPresentAd()
    }
    
    // MARK: - Interstitial Ad
    func loadInterstitialAd() {
        InterstitialAdsManager.shared.loadAd()
    }
    
    func showInterstitialAd(from viewController: UIViewController,
                            completion: @escaping () -> Void) {
        InterstitialAdsManager.shared.showAd(from: viewController, completion: completion)
    }

    // MARK: - Banner Ad
    func loadBannerAd(in containerView: UIView,
                      rootViewController: UIViewController,
                      completion: @escaping (Bool) -> Void) {
        BannerAdsManager.shared.loadBannerAd(in: containerView, vc: rootViewController, completion: completion)
    }

    // MARK: - Native Ad
    func loadNativeAd(in containerView: UIView,
                      adType: AdType,
                      completion: @escaping (Bool) -> Void) {
        containerView.clipsToBounds = true
        NativeAdsManager.shared.getAd(in: containerView, adType: adType, completion: completion)
    }
}
