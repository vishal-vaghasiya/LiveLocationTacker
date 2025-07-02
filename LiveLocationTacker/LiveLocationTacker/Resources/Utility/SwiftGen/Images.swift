// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let color00000020 = ColorAsset(name: "Color-000000-20")
  internal static let color00000030 = ColorAsset(name: "Color-000000-30")
  internal static let color000000 = ColorAsset(name: "Color-000000")
  internal static let color001117 = ColorAsset(name: "Color-001117")
  internal static let color00131A = ColorAsset(name: "Color-00131A")
  internal static let color00BDFF10 = ColorAsset(name: "Color-00BDFF-10")
  internal static let color00BDFF15 = ColorAsset(name: "Color-00BDFF-15")
  internal static let color00BDFF20 = ColorAsset(name: "Color-00BDFF-20")
  internal static let color00BDFF = ColorAsset(name: "Color-00BDFF")
  internal static let color02020230 = ColorAsset(name: "Color-020202-30")
  internal static let color1C2327 = ColorAsset(name: "Color-1C2327")
  internal static let color213034 = ColorAsset(name: "Color-213034")
  internal static let color334248 = ColorAsset(name: "Color-334248")
  internal static let color404C50 = ColorAsset(name: "Color-404C50")
  internal static let color7C7C80 = ColorAsset(name: "Color-7C7C80")
  internal static let color7E888B = ColorAsset(name: "Color-7E888B")
  internal static let color8C9496 = ColorAsset(name: "Color-8C9496")
  internal static let colorFF3B30 = ColorAsset(name: "Color-FF3B30")
  internal static let colorFF6961 = ColorAsset(name: "Color-FF6961")
  internal static let colorFFFFFF10 = ColorAsset(name: "Color-FFFFFF-10")
  internal static let colorFFFFFF15 = ColorAsset(name: "Color-FFFFFF-15")
  internal static let colorFFFFFF20 = ColorAsset(name: "Color-FFFFFF-20")
  internal static let colorFFFFFF = ColorAsset(name: "Color-FFFFFF")
  internal static let backgroundColor = ColorAsset(name: "backgroundColor")
  internal static let bgcolor = ColorAsset(name: "bgcolor")
  internal static let btncolor = ColorAsset(name: "btncolor")
  internal static let cellBg = ColorAsset(name: "cell_bg")
  internal static let fontBlackcolor = ColorAsset(name: "fontBlackcolor")
  internal static let fontGraycolor = ColorAsset(name: "fontGraycolor")
  internal static let fontcolor = ColorAsset(name: "fontcolor")
  internal static let maincolor = ColorAsset(name: "maincolor")
  internal static let txtBgcolor = ColorAsset(name: "txt_bgcolor")
  internal static let iconChildmodeOnImage = ImageAsset(name: "icon_childmode_on_image")
  internal static let iconLogout = ImageAsset(name: "icon_logout")
  internal static let iconPermissionDenied = ImageAsset(name: "icon_permission_denied")
  internal static let iconPermissionLocked = ImageAsset(name: "icon_permission_locked")
  internal static let hybridMap = ImageAsset(name: "hybrid_map")
  internal static let satelliteMap = ImageAsset(name: "satellite_map")
  internal static let standardMap = ImageAsset(name: "standard_map")
  internal static let stars35 = ImageAsset(name: "stars_3_5")
  internal static let stars4 = ImageAsset(name: "stars_4")
  internal static let stars45 = ImageAsset(name: "stars_4_5")
  internal static let stars5 = ImageAsset(name: "stars_5")
  internal static let iconPermissionBattery = ImageAsset(name: "icon_permission_battery")
  internal static let iconPermissionCamera = ImageAsset(name: "icon_permission_camera")
  internal static let iconPermissionCamera1 = ImageAsset(name: "icon_permission_camera_1")
  internal static let iconPermissionLocation = ImageAsset(name: "icon_permission_location")
  internal static let iconPermissionMotion = ImageAsset(name: "icon_permission_motion")
  internal static let iconPermissionNotification = ImageAsset(name: "icon_permission_notification")
  internal static let activeLogo = ImageAsset(name: "active_logo")
  internal static let freeTrialBg = ImageAsset(name: "free_trial_bg")
  internal static let icPro = ImageAsset(name: "ic_Pro")
  internal static let icSelect = ImageAsset(name: "ic_select")
  internal static let icUnselect = ImageAsset(name: "ic_unselect")
  internal static let iconPremiumBattery = ImageAsset(name: "icon_premium_battery")
  internal static let iconPremiumBatteryDisable = ImageAsset(name: "icon_premium_battery_disable")
  internal static let iconPremiumLocation = ImageAsset(name: "icon_premium_location")
  internal static let iconPremiumLocationDisable = ImageAsset(name: "icon_premium_location_disable")
  internal static let iconPremiumNoAds = ImageAsset(name: "icon_premium_noAds")
  internal static let iconPremiumNoAdsDisable = ImageAsset(name: "icon_premium_noAds_disable")
  internal static let iconPremiumNotification = ImageAsset(name: "icon_premium_notification")
  internal static let iconPremiumNotificationDisable = ImageAsset(name: "icon_premium_notification_disable")
  internal static let iconTickCircle = ImageAsset(name: "icon_tick_circle")
  internal static let iconTickCircleSelected = ImageAsset(name: "icon_tick_circle_selected")
  internal static let iconWatch = ImageAsset(name: "icon_watch")
  internal static let proBanner = ImageAsset(name: "pro_banner")
  internal static let proBanner0 = ImageAsset(name: "pro_banner0")
  internal static let bgCircle = ImageAsset(name: "bg_circle")
  internal static let bgPopup = ImageAsset(name: "bg_popup")
  internal static let blurView = ImageAsset(name: "blur_view")
  internal static let btnBg = ImageAsset(name: "btn_bg")
  internal static let buttonBg3 = ImageAsset(name: "button_bg_3")
  internal static let female = ImageAsset(name: "female")
  internal static let group35291 = ImageAsset(name: "Group 3529-1")
  internal static let group3529 = ImageAsset(name: "Group 3529")
  internal static let group3994 = ImageAsset(name: "Group 3994")
  internal static let vector2 = ImageAsset(name: "Vector 2")
  internal static let vector3 = ImageAsset(name: "Vector 3")
  internal static let battery = ImageAsset(name: "battery")
  internal static let engineer = ImageAsset(name: "engineer")
  internal static let gps = ImageAsset(name: "gps")
  internal static let gpsIc = ImageAsset(name: "gps_ic")
  internal static let maptype = ImageAsset(name: "maptype")
  internal static let minues = ImageAsset(name: "minues")
  internal static let pinMap = ImageAsset(name: "pin-map")
  internal static let plus = ImageAsset(name: "plus")
  internal static let reset = ImageAsset(name: "reset")
  internal static let sos = ImageAsset(name: "sos")
  internal static let iconArrowBack = ImageAsset(name: "icon_arrow_back")
  internal static let iconArrowNext = ImageAsset(name: "icon_arrow_next")
  internal static let iconArrowNextBlue = ImageAsset(name: "icon_arrow_next_blue")
  internal static let iconArrowNextDisable = ImageAsset(name: "icon_arrow_next_disable")
  internal static let iconArrowWhiteDown = ImageAsset(name: "icon_arrow_white_down")
  internal static let iconArrowWhiteUp = ImageAsset(name: "icon_arrow_white_up")
  internal static let iconBackSquare = ImageAsset(name: "icon_back_square")
  internal static let iconDisableButton = ImageAsset(name: "icon_disable_button")
  internal static let iconEditPencil = ImageAsset(name: "icon_edit_pencil")
  internal static let iconEnableButton = ImageAsset(name: "icon_enable_button")
  internal static let iconInfoCircle = ImageAsset(name: "icon_info_circle")
  internal static let iconRadio = ImageAsset(name: "icon_radio")
  internal static let iconRadioSelected = ImageAsset(name: "icon_radio_selected")
  internal static let iconShare = ImageAsset(name: "icon_share")
  internal static let iconSosFailed = ImageAsset(name: "icon_sos_failed")
  internal static let male = ImageAsset(name: "male")
  internal static let union = ImageAsset(name: "Union")
  internal static let iconDarkMode = ImageAsset(name: "icon_dark_mode")
  internal static let iconFeedbackApp = ImageAsset(name: "icon_feedback_app")
  internal static let iconPermissionChildmode = ImageAsset(name: "icon_permission_childmode")
  internal static let iconPrivacyPolicy = ImageAsset(name: "icon_privacy_policy")
  internal static let iconRateUs = ImageAsset(name: "icon_rate_us")
  internal static let iconShareApp = ImageAsset(name: "icon_share_app")
  internal static let iconSubscription = ImageAsset(name: "icon_subscription")
  internal static let iconTermCondition = ImageAsset(name: "icon_term_condition")
  internal static let premium = ImageAsset(name: "premium")
  internal static let shareBtnBg = ImageAsset(name: "share_btn_bg")
  internal static let group3469 = ImageAsset(name: "Group 3469")
  internal static let photo = ImageAsset(name: "Photo")
  internal static let bgSelectProfile = ImageAsset(name: "bg_select_profile")
  internal static let icIntro = ImageAsset(name: "ic_intro")
  internal static let icSplash = ImageAsset(name: "ic_splash")
  internal static let iconDefaultProfile = ImageAsset(name: "icon_default_profile")
  internal static let iconEditProfile = ImageAsset(name: "icon_edit_profile")
  internal static let iconPerson = ImageAsset(name: "icon_person")
  internal static let logo = ImageAsset(name: "logo")
  internal static let onboard1 = ImageAsset(name: "onboard_1")
  internal static let onboard2 = ImageAsset(name: "onboard_2")
  internal static let onboard3 = ImageAsset(name: "onboard_3")
  internal static let pagecontrolSelect = ImageAsset(name: "pagecontrol_select")
  internal static let pagecontrolUnselect = ImageAsset(name: "pagecontrol_unselect")
  internal static let tab1 = ImageAsset(name: "tab_1")
  internal static let tab2 = ImageAsset(name: "tab_2")
  internal static let tab3 = ImageAsset(name: "tab_3")
  internal static let tab4 = ImageAsset(name: "tab_4")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
