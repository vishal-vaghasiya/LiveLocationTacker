//
//  Model.swift
//  ScreenMirroring
//
//  Created by DREAMWORLD on 13/09/24.
//

import Foundation
import UIKit


// MARK: - AdsDataModel -

struct AdsDataModel: Codable {
    let appOpenIDAds, interstitialIDAds, bannerIDAds, nativeIDAds: String?
    let appOpenIDOneAds, interstitialIDOneAds, bannerIDOneAds, nativeIDOneAds: String?
    let splashAds, bannerAds, interstitialAds, nativeAds: String?
    let appOpenAds, introPurchaseAds, nativeButtonAds: String?
    let interstitialCountAds, interstitialCountShowAds: Int?

    enum CodingKeys: String, CodingKey {
        case appOpenIDAds = "app_open_id_ads"
        case interstitialIDAds = "interstitial_id_ads"
        case bannerIDAds = "banner_id_ads"
        case nativeIDAds = "native_id_ads"
        case appOpenIDOneAds = "app_open_id_one_ads"
        case interstitialIDOneAds = "interstitial_id_one_ads"
        case bannerIDOneAds = "banner_id_one_ads"
        case nativeIDOneAds = "native_id_one_ads"
        case splashAds = "splash_ads"
        case bannerAds = "banner_ads"
        case interstitialAds = "interstitial_ads"
        case nativeAds = "native_ads"
        case appOpenAds = "app_open_ads"
        case introPurchaseAds = "intro_purchase_ads"
        case nativeButtonAds = "native_button_ads"
        case interstitialCountAds = "interstitial_count_ads"
        case interstitialCountShowAds = "interstitial_count_show_ads"
    }
}

enum SettingOptions {
    case CHILD_MODE
    case DARK_MODE
    
    case RATE_NOW
    case SHARE
    case FEEDBACK
    case PRIVACY_POLICY
    case TERMS_CONDITION
    case SUBSCRIPTION
}

struct AppCommonModel {
    var id: SettingOptions
    var image:UIImage?
    var title:String?
    var subtitle:String?
    var outerViewColor:UIColor?
}

struct UserLocationModel {
    let latitude: Double
    let longitude: Double
    let timestamp: Int

    init?(from dict: [String: Any]) {
        guard let lat = dict["latitude"] as? Double,
              let lon = dict["longitude"] as? Double,
              let ts = dict["timestamp"] as? Int else {
            return nil
        }
        self.latitude = lat
        self.longitude = lon
        self.timestamp = ts
    }
}
