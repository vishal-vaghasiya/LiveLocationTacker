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
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let stars35 = ImageAsset(name: "stars_3_5")
  internal static let stars4 = ImageAsset(name: "stars_4")
  internal static let stars45 = ImageAsset(name: "stars_4_5")
  internal static let stars5 = ImageAsset(name: "stars_5")
  internal static let icPro = ImageAsset(name: "ic_Pro")
  internal static let icSelect = ImageAsset(name: "ic_select")
  internal static let icUnselect = ImageAsset(name: "ic_unselect")
  internal static let proBanner = ImageAsset(name: "pro_banner")
  internal static let btnBg = ImageAsset(name: "btn_bg")
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
  internal static let iconArrowNext = ImageAsset(name: "icon_arrow_next")
  internal static let iconArrowNextDisable = ImageAsset(name: "icon_arrow_next_disable")
  internal static let male = ImageAsset(name: "male")
  internal static let group3453 = ImageAsset(name: "Group 3453")
  internal static let group3454 = ImageAsset(name: "Group 3454")
  internal static let group3455 = ImageAsset(name: "Group 3455")
  internal static let union = ImageAsset(name: "Union")
  internal static let icSetting1 = ImageAsset(name: "ic_setting_1")
  internal static let icSetting2 = ImageAsset(name: "ic_setting_2")
  internal static let icSetting3 = ImageAsset(name: "ic_setting_3")
  internal static let icSetting4 = ImageAsset(name: "ic_setting_4")
  internal static let icSetting5 = ImageAsset(name: "ic_setting_5")
  internal static let icSetting6 = ImageAsset(name: "ic_setting_6")
  internal static let premium = ImageAsset(name: "premium")
  internal static let shareBtnBg = ImageAsset(name: "share_btn_bg")
  internal static let group3469 = ImageAsset(name: "Group 3469")
  internal static let photo = ImageAsset(name: "Photo")
  internal static let bgSelectProfile = ImageAsset(name: "bg_select_profile")
  internal static let icIntro = ImageAsset(name: "ic_intro")
  internal static let icSplash = ImageAsset(name: "ic_splash")
  internal static let iconDefaultProfile = ImageAsset(name: "icon_default_profile")
  internal static let iconDisableButton = ImageAsset(name: "icon_disable_button")
  internal static let iconEditProfile = ImageAsset(name: "icon_edit_profile")
  internal static let iconEnableButton = ImageAsset(name: "icon_enable_button")
  internal static let iconPermissionCamera = ImageAsset(name: "icon_permission_camera")
  internal static let iconPermissionLocation = ImageAsset(name: "icon_permission_location")
  internal static let iconPermissionMotion = ImageAsset(name: "icon_permission_motion")
  internal static let iconPermissionNotification = ImageAsset(name: "icon_permission_notification")
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
