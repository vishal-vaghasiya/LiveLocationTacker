// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length implicit_return

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:disable type_body_length type_name
internal enum StoryboardScene {
  internal enum AuthFlow: StoryboardType {
    internal static let storyboardName = "AuthFlow"

    internal static let otpVerificationVC = SceneType<LocationTracker.OTPVerificationVC>(storyboard: AuthFlow.self, identifier: "OTPVerificationVC")

    internal static let phoneAuthVC = SceneType<LocationTracker.PhoneAuthVC>(storyboard: AuthFlow.self, identifier: "PhoneAuthVC")
  }
  internal enum Child: StoryboardType {
    internal static let storyboardName = "Child"

    internal static let aboutChildModeVC = SceneType<LocationTracker.AboutChildModeVC>(storyboard: Child.self, identifier: "AboutChildModeVC")

    internal static let childModeAddPopupVC = SceneType<LocationTracker.ChildModeAddPopupVC>(storyboard: Child.self, identifier: "ChildModeAddPopupVC")

    internal static let childModeCircleListVC = SceneType<LocationTracker.ChildModeCircleListVC>(storyboard: Child.self, identifier: "ChildModeCircleListVC")

    internal static let childModeMemberListVC = SceneType<LocationTracker.ChildModeMemberListVC>(storyboard: Child.self, identifier: "ChildModeMemberListVC")

    internal static let childModeVC = SceneType<LocationTracker.ChildModeVC>(storyboard: Child.self, identifier: "ChildModeVC")

    internal static let disableRequestPopupVC = SceneType<LocationTracker.DisableRequestPopupVC>(storyboard: Child.self, identifier: "DisableRequestPopupVC")

    internal static let popupEnableChildmode = SceneType<LocationTracker.PopupEnableChildmode>(storyboard: Child.self, identifier: "PopupEnableChildmode")

    internal static let popupRequestToDisable = SceneType<LocationTracker.PopupRequestToDisable>(storyboard: Child.self, identifier: "PopupRequestToDisable")
  }
  internal enum Circle: StoryboardType {
    internal static let storyboardName = "Circle"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Circle.self)

    internal static let addMemberVC = SceneType<LocationTracker.AddMemberVC>(storyboard: Circle.self, identifier: "AddMemberVC")

    internal static let circleVC = SceneType<LocationTracker.CircleVC>(storyboard: Circle.self, identifier: "CircleVC")

    internal static let commonAlertPopup = SceneType<LocationTracker.CommonAlertPopup>(storyboard: Circle.self, identifier: "CommonAlertPopup")

    internal static let createCircleVC = SceneType<LocationTracker.CreateCircleVC>(storyboard: Circle.self, identifier: "CreateCircleVC")

    internal static let joinCircleVC = SceneType<LocationTracker.JoinCircleVC>(storyboard: Circle.self, identifier: "JoinCircleVC")

    internal static let memberVC = SceneType<LocationTracker.MemberVC>(storyboard: Circle.self, identifier: "MemberVC")

    internal static let popupCIrcleList = SceneType<LocationTracker.PopupCIrcleList>(storyboard: Circle.self, identifier: "PopupCIrcleList")

    internal static let popupMapSettings = SceneType<LocationTracker.PopupMapSettings>(storyboard: Circle.self, identifier: "PopupMapSettings")

    internal static let popupUserInfo = SceneType<LocationTracker.PopupUserInfo>(storyboard: Circle.self, identifier: "PopupUserInfo")

    internal static let sosCallingVC = SceneType<LocationTracker.SOSCallingVC>(storyboard: Circle.self, identifier: "SOSCallingVC")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Main.self)

    internal static let onboardingVC = SceneType<LocationTracker.OnboardingVC>(storyboard: Main.self, identifier: "OnboardingVC")

    internal static let selectLanguageVC = SceneType<LocationTracker.SelectLanguageVC>(storyboard: Main.self, identifier: "SelectLanguageVC")

    internal static let splashScreenVC = SceneType<LocationTracker.SplashScreenVC>(storyboard: Main.self, identifier: "SplashScreenVC")

    internal static let welcomeVC = SceneType<LocationTracker.WelcomeVC>(storyboard: Main.self, identifier: "WelcomeVC")
  }
  internal enum Permission: StoryboardType {
    internal static let storyboardName = "Permission"

    internal static let initialScene = InitialSceneType<LocationTracker.SetupPermissionVC>(storyboard: Permission.self)

    internal static let setupPermissionVC = SceneType<LocationTracker.SetupPermissionVC>(storyboard: Permission.self, identifier: "SetupPermissionVC")
  }
  internal enum Premium: StoryboardType {
    internal static let storyboardName = "Premium"

    internal static let premiumVC = SceneType<LocationTracker.PremiumVC>(storyboard: Premium.self, identifier: "PremiumVC")

    internal static let subscriptionListVC = SceneType<LocationTracker.SubscriptionListVC>(storyboard: Premium.self, identifier: "SubscriptionListVC")
  }
  internal enum Profile: StoryboardType {
    internal static let storyboardName = "Profile"

    internal static let editProfileVC = SceneType<LocationTracker.EditProfileVC>(storyboard: Profile.self, identifier: "EditProfileVC")

    internal static let setProfilePicVC = SceneType<LocationTracker.SetProfilePicVC>(storyboard: Profile.self, identifier: "SetProfilePicVC")

    internal static let setupProfileVC = SceneType<LocationTracker.SetupProfileVC>(storyboard: Profile.self, identifier: "SetupProfileVC")
  }
  internal enum Proximity: StoryboardType {
    internal static let storyboardName = "Proximity"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Proximity.self)

    internal static let addProximityVC = SceneType<LocationTracker.AddProximityVC>(storyboard: Proximity.self, identifier: "AddProximityVC")

    internal static let openMapVC = SceneType<LocationTracker.OpenMapVC>(storyboard: Proximity.self, identifier: "OpenMapVC")

    internal static let proximityAlertListVC = SceneType<LocationTracker.ProximityAlertListVC>(storyboard: Proximity.self, identifier: "ProximityAlertListVC")

    internal static let proximityInfoVC = SceneType<LocationTracker.ProximityInfoVC>(storyboard: Proximity.self, identifier: "ProximityInfoVC")

    internal static let proximityVC = SceneType<LocationTracker.ProximityVC>(storyboard: Proximity.self, identifier: "ProximityVC")
  }
  internal enum Settings: StoryboardType {
    internal static let storyboardName = "Settings"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Settings.self)

    internal static let settingsVC = SceneType<LocationTracker.SettingsVC>(storyboard: Settings.self, identifier: "SettingsVC")
  }
  internal enum TabBar: StoryboardType {
    internal static let storyboardName = "TabBar"

    internal static let initialScene = InitialSceneType<LocationTracker.MainTabBarController>(storyboard: TabBar.self)

    internal static let mainTabBarController = SceneType<LocationTracker.MainTabBarController>(storyboard: TabBar.self, identifier: "MainTabBarController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:enable type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: block)
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController(creator: block) else {
      fatalError("Storyboard \(storyboard.storyboardName) does not have an initial scene.")
    }
    return controller
  }
}

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
