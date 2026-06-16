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
  internal static let backgroundActiveplan = ImageAsset(name: "background.activeplan")
  internal static let backgroundCircle = ImageAsset(name: "background.circle")
  internal static let backgroundCircleSos = ImageAsset(name: "background.circle.sos")
  internal static let backgroundFreetrial = ImageAsset(name: "background.freetrial")
  internal static let backgroundPopup = ImageAsset(name: "background.popup")
  internal static let backgroundPremiumCell = ImageAsset(name: "background.premium.cell")
  internal static let backgroundPremium = ImageAsset(name: "background.premium")
  internal static let gradientBgBlue = ImageAsset(name: "gradient_bg_blue")
  internal static let gradientBgGray = ImageAsset(name: "gradient_bg_gray")
  internal static let gradientBgRed = ImageAsset(name: "gradient_bg_red")
  internal static let iconLogoBackground = ImageAsset(name: "icon_logo_background")
  internal static let sosBackground = ImageAsset(name: "sos_background")
  internal static let splashBg = ImageAsset(name: "splash-bg")
  internal static let welcomeUnderline = ImageAsset(name: "welcome.underline")
  internal static let welcomeBg = ImageAsset(name: "welcome_bg")
  internal static let arrow = ImageAsset(name: "arrow")
  internal static let backgroundCompass = ImageAsset(name: "background.compass")
  internal static let iconFlagBulgarian = ImageAsset(name: "icon_flag_Bulgarian")
  internal static let iconFlagDanish = ImageAsset(name: "icon_flag_Danish")
  internal static let iconFlagDutch = ImageAsset(name: "icon_flag_Dutch")
  internal static let iconFlagEnglish = ImageAsset(name: "icon_flag_English")
  internal static let iconFlagFilipino = ImageAsset(name: "icon_flag_Filipino")
  internal static let iconFlagFrench = ImageAsset(name: "icon_flag_French")
  internal static let iconFlagGerman = ImageAsset(name: "icon_flag_German")
  internal static let iconFlagGreek = ImageAsset(name: "icon_flag_Greek")
  internal static let iconFlagHausa = ImageAsset(name: "icon_flag_Hausa")
  internal static let iconFlagHindi = ImageAsset(name: "icon_flag_Hindi")
  internal static let iconFlagIndonesian = ImageAsset(name: "icon_flag_Indonesian")
  internal static let iconFlagItalian = ImageAsset(name: "icon_flag_Italian")
  internal static let iconFlagJapanese = ImageAsset(name: "icon_flag_Japanese")
  internal static let iconFlagMalay = ImageAsset(name: "icon_flag_Malay")
  internal static let iconFlagPolish = ImageAsset(name: "icon_flag_Polish")
  internal static let iconFlagPortuguese = ImageAsset(name: "icon_flag_Portuguese")
  internal static let iconFlagRomanian = ImageAsset(name: "icon_flag_Romanian")
  internal static let iconFlagRussian = ImageAsset(name: "icon_flag_Russian")
  internal static let iconFlagSpanish = ImageAsset(name: "icon_flag_Spanish")
  internal static let iconFlagSwedish = ImageAsset(name: "icon_flag_Swedish")
  internal static let iconFlagThai = ImageAsset(name: "icon_flag_Thai")
  internal static let iconFlagTurkish = ImageAsset(name: "icon_flag_Turkish")
  internal static let iconFlagVietnamese = ImageAsset(name: "icon_flag_Vietnamese")
  internal static let iconFlagAfrikaans = ImageAsset(name: "icon_flag_afrikaans")
  internal static let iconFlagLatin = ImageAsset(name: "icon_flag_latin")
  internal static let iconFlagLatvian = ImageAsset(name: "icon_flag_latvian")
  internal static let iconFlagSomali = ImageAsset(name: "icon_flag_somali")
  internal static let arrowBackSqure = ImageAsset(name: "arrow.back.squre")
  internal static let arrowDownWhite = ImageAsset(name: "arrow.down.white")
  internal static let arrowLeft = ImageAsset(name: "arrow.left")
  internal static let arrowNextBlue = ImageAsset(name: "arrow.next.blue")
  internal static let buttonChangeMap = ImageAsset(name: "button.change.map")
  internal static let buttonCurrentLocation = ImageAsset(name: "button.current.location")
  internal static let buttonPremium = ImageAsset(name: "button.premium")
  internal static let buttonRadio = ImageAsset(name: "button.radio")
  internal static let buttonRadioSelected = ImageAsset(name: "button.radio.selected")
  internal static let buttonShare = ImageAsset(name: "button.share")
  internal static let buttonSos = ImageAsset(name: "button.sos")
  internal static let buttonTickBlue = ImageAsset(name: "button.tick.blue")
  internal static let iconCalender = ImageAsset(name: "icon.calender")
  internal static let iconAddressPin = ImageAsset(name: "icon_address_pin")
  internal static let iconBattery = ImageAsset(name: "icon_battery")
  internal static let iconClose = ImageAsset(name: "icon_close")
  internal static let iconContact = ImageAsset(name: "icon_contact")
  internal static let iconCopy = ImageAsset(name: "icon_copy")
  internal static let iconDown = ImageAsset(name: "icon_down")
  internal static let iconEdit = ImageAsset(name: "icon_edit")
  internal static let iconMembar = ImageAsset(name: "icon_membar")
  internal static let iconZoomIn = ImageAsset(name: "icon_zoom_in")
  internal static let iconZoomOut = ImageAsset(name: "icon_zoom_out")
  internal static let mapTransit = ImageAsset(name: "map.Transit")
  internal static let mapHybrid = ImageAsset(name: "map.hybrid")
  internal static let mapSatelite = ImageAsset(name: "map.satelite")
  internal static let mapStandard = ImageAsset(name: "map.standard")
  internal static let appLogo = ImageAsset(name: "app_logo")
  internal static let appnameText = ImageAsset(name: "appname_text")
  internal static let iconPhoneLogo = ImageAsset(name: "icon.phone.logo")
  internal static let iconChildLogo = ImageAsset(name: "icon_child_logo")
  internal static let iconBatteryLevel = ImageAsset(name: "icon_battery_level")
  internal static let iconLogout = ImageAsset(name: "icon_logout")
  internal static let iconPermissionCamera = ImageAsset(name: "icon_permission_camera")
  internal static let iconPermissionLocation = ImageAsset(name: "icon_permission_location")
  internal static let iconPermissionLogo = ImageAsset(name: "icon_permission_logo")
  internal static let iconPermissionMotion = ImageAsset(name: "icon_permission_motion")
  internal static let iconPermissionNotification = ImageAsset(name: "icon_permission_notification")
  internal static let logoPermissionLocationSharing = ImageAsset(name: "logo_permission_location_sharing")
  internal static let logoPermissionMotionActivity = ImageAsset(name: "logo_permission_motion_activity")
  internal static let iconPremiumBatteryDisable = ImageAsset(name: "icon.premium.battery.disable")
  internal static let iconPremiumBattery = ImageAsset(name: "icon.premium.battery")
  internal static let iconPremiumLocationDisable = ImageAsset(name: "icon.premium.location.disable")
  internal static let iconPremiumLocation = ImageAsset(name: "icon.premium.location")
  internal static let iconPremiumNoAdsDisable = ImageAsset(name: "icon.premium.noAds.disable")
  internal static let iconPremiumNoAds = ImageAsset(name: "icon.premium.noAds")
  internal static let iconPremiumNotificationDisable = ImageAsset(name: "icon.premium.notification.disable")
  internal static let iconPremiumNotification = ImageAsset(name: "icon.premium.notification")
  internal static let iconTickcircle = ImageAsset(name: "icon.tickcircle")
  internal static let iconTickcircleSelected = ImageAsset(name: "icon.tickcircle.selected")
  internal static let addressPin = ImageAsset(name: "address.pin")
  internal static let pinEducation = ImageAsset(name: "pin.education")
  internal static let pinGym = ImageAsset(name: "pin.gym")
  internal static let pinHome = ImageAsset(name: "pin.home")
  internal static let pinHospital = ImageAsset(name: "pin.hospital")
  internal static let pinOffice = ImageAsset(name: "pin.office")
  internal static let pinOther = ImageAsset(name: "pin.other")
  internal static let pinShop = ImageAsset(name: "pin.shop")
  internal static let proxiTypeEducation = ImageAsset(name: "proxi.type.education")
  internal static let proxiTypeGym = ImageAsset(name: "proxi.type.gym")
  internal static let proxiTypeHome = ImageAsset(name: "proxi.type.home")
  internal static let proxiTypeHospital = ImageAsset(name: "proxi.type.hospital")
  internal static let proxiTypeOffice = ImageAsset(name: "proxi.type.office")
  internal static let proxiTypeOther = ImageAsset(name: "proxi.type.other")
  internal static let proxiTypeShop = ImageAsset(name: "proxi.type.shop")
  internal static let childmodePermission = ImageAsset(name: "childmode.permission")
  internal static let iconChangeLanguage = ImageAsset(name: "icon.change.language")
  internal static let iconFeedbackApp = ImageAsset(name: "icon.feedback.app")
  internal static let iconPrivacypolicyApp = ImageAsset(name: "icon.privacypolicy.app")
  internal static let iconRateApp = ImageAsset(name: "icon.rate.app")
  internal static let iconRemove = ImageAsset(name: "icon.remove")
  internal static let iconShareApp = ImageAsset(name: "icon.share.app")
  internal static let iconSubscription = ImageAsset(name: "icon.subscription")
  internal static let iconTermconditionApp = ImageAsset(name: "icon.termcondition.app")
  internal static let settingLocationSharing = ImageAsset(name: "setting.location.sharing")
  internal static let settingsAccessCamera = ImageAsset(name: "settings.access.camera")
  internal static let settingsBatterySharing = ImageAsset(name: "settings.battery.sharing")
  internal static let settingsMotionActivity = ImageAsset(name: "settings.motion.activity")
  internal static let settingsPlaceNotifiication = ImageAsset(name: "settings.place.notifiication")
  internal static let bgSelectProfile = ImageAsset(name: "bg_select_profile")
  internal static let buttonPencil = ImageAsset(name: "button.pencil")
  internal static let femaleDefault = ImageAsset(name: "female_default")
  internal static let femaleSelected = ImageAsset(name: "female_selected")
  internal static let iconDefaultProfile = ImageAsset(name: "icon.default.profile")
  internal static let iconEditProfile = ImageAsset(name: "icon.edit.profile")
  internal static let iconSelectProfile = ImageAsset(name: "icon_select_profile")
  internal static let maleDefault = ImageAsset(name: "male_default")
  internal static let maleSelected = ImageAsset(name: "male_selected")
  internal static let mapUn = ImageAsset(name: "Map_un")
  internal static let placeUn = ImageAsset(name: "Place_un")
  internal static let settingUn = ImageAsset(name: "Setting_un")
  internal static let mapSelected = ImageAsset(name: "map_Selected")
  internal static let placeSelected = ImageAsset(name: "place_Selected")
  internal static let settingMapSelected = ImageAsset(name: "setting_map_Selected")
  internal static let tabCircle = ImageAsset(name: "tab_circle")
  internal static let tabCircleSelected = ImageAsset(name: "tab_circle_selected")
  internal static let arrowDownWhite1 = ImageAsset(name: "arrow.down.white1")
  internal static let arrowNextWhite = ImageAsset(name: "arrow.next.white")
  internal static let arrowUpWhite1 = ImageAsset(name: "arrow.up.white1")
  internal static let buttonMoreBlue = ImageAsset(name: "button.more.blue")
  internal static let buttonPlus = ImageAsset(name: "button.plus")
  internal static let enableChildInfo = ImageAsset(name: "enable.child.info")
  internal static let iconChildLogout = ImageAsset(name: "icon.child.logout")
  internal static let iconErrorInfo = ImageAsset(name: "icon.error.info")
  internal static let iconInfoCircle = ImageAsset(name: "icon.info.circle")
  internal static let iconLock = ImageAsset(name: "icon.lock")
  internal static let iconNagativeResult = ImageAsset(name: "icon.nagative.result")
  internal static let iconNotificationRed = ImageAsset(name: "icon.notification.red")
  internal static let iconSearch = ImageAsset(name: "icon.search")
  internal static let iconSuccessTick = ImageAsset(name: "icon.success.tick")
  internal static let iconWatch = ImageAsset(name: "icon.watch")
  internal static let iconArrowNext = ImageAsset(name: "icon_arrow_next")
  internal static let iconNoInternet = ImageAsset(name: "icon_no_internet")
  internal static let iconPerson = ImageAsset(name: "icon_person")
  internal static let iconPlusBlue = ImageAsset(name: "icon_plus_blue")
  internal static let iconTick = ImageAsset(name: "icon_tick")
  internal static let iconVerify = ImageAsset(name: "icon_verify")
  internal static let onboarding1 = ImageAsset(name: "onboarding_1")
  internal static let onboarding2 = ImageAsset(name: "onboarding_2")
  internal static let onboarding3 = ImageAsset(name: "onboarding_3")
  internal static let pinAddressWhite = ImageAsset(name: "pin.address.white")
  internal static let sliderThumb = ImageAsset(name: "sliderThumb")
  internal static let sosFailed = ImageAsset(name: "sos.failed")
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let appBackground = ColorAsset(name: "AppBackground")
  internal static let appBlack = ColorAsset(name: "AppBlack")
  internal static let appDarkGrey = ColorAsset(name: "AppDarkGrey")
  internal static let appGreen = ColorAsset(name: "AppGreen")
  internal static let appLight = ColorAsset(name: "AppLight")
  internal static let appLightGrey = ColorAsset(name: "AppLightGrey")
  internal static let appMain = ColorAsset(name: "AppMain")
  internal static let appMain10 = ColorAsset(name: "AppMain10")
  internal static let appRed = ColorAsset(name: "AppRed")
  internal static let appRed10 = ColorAsset(name: "AppRed10")
  internal static let appShadowBlack = ColorAsset(name: "AppShadowBlack")
  internal static let appShadowBlue = ColorAsset(name: "AppShadowBlue")
  internal static let appSubTitle = ColorAsset(name: "AppSubTitle")
  internal static let appWhite = ColorAsset(name: "AppWhite")
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
