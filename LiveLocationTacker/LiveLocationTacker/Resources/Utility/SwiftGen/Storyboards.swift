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
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Main.self)

    internal static let introVC = SceneType<LiveLocationTacker.IntroVC>(storyboard: Main.self, identifier: "IntroVC")

    internal static let loginMobilenumberVC = SceneType<LiveLocationTacker.LoginMobilenumberVC>(storyboard: Main.self, identifier: "LoginMobilenumberVC")

    internal static let mainSplashVC = SceneType<LiveLocationTacker.MainSplashVC>(storyboard: Main.self, identifier: "MainSplashVC")

    internal static let mobileOTPVerificationVC = SceneType<LiveLocationTacker.MobileOTPVerificationVC>(storyboard: Main.self, identifier: "MobileOTPVerificationVC")

    internal static let onBoardingVC = SceneType<LiveLocationTacker.OnBoardingVC>(storyboard: Main.self, identifier: "OnBoardingVC")

    internal static let permissionVC = SceneType<LiveLocationTacker.PermissionVC>(storyboard: Main.self, identifier: "PermissionVC")

    internal static let photoPickerPopup = SceneType<LiveLocationTacker.PhotoPickerPopup>(storyboard: Main.self, identifier: "PhotoPickerPopup")

    internal static let setProfileVC = SceneType<LiveLocationTacker.SetProfileVC>(storyboard: Main.self, identifier: "SetProfileVC")

    internal static let subscribeVC = SceneType<LiveLocationTacker.SubscribeVC>(storyboard: Main.self, identifier: "SubscribeVC")
  }
  internal enum Settings: StoryboardType {
    internal static let storyboardName = "Settings"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Settings.self)

    internal static let profileVC = SceneType<LiveLocationTacker.ProfileVC>(storyboard: Settings.self, identifier: "ProfileVC")

    internal static let settingVC = SceneType<LiveLocationTacker.SettingVC>(storyboard: Settings.self, identifier: "SettingVC")
  }
  internal enum TabBar: StoryboardType {
    internal static let storyboardName = "TabBar"

    internal static let aremaCalculatoreVC = SceneType<LiveLocationTacker.AremaCalculatoreVC>(storyboard: TabBar.self, identifier: "AremaCalculatoreVC")

    internal static let compassVC = SceneType<LiveLocationTacker.CompassVC>(storyboard: TabBar.self, identifier: "CompassVC")

    internal static let homeTabVC = SceneType<LiveLocationTacker.HomeTabVC>(storyboard: TabBar.self, identifier: "HomeTabVC")

    internal static let joinCircleVC = SceneType<LiveLocationTacker.JoinCircleVC>(storyboard: TabBar.self, identifier: "JoinCircleVC")

    internal static let mapSettingsVC = SceneType<LiveLocationTacker.MapSettingsVC>(storyboard: TabBar.self, identifier: "MapSettingsVC")

    internal static let mapVC = SceneType<LiveLocationTacker.MapVC>(storyboard: TabBar.self, identifier: "MapVC")

    internal static let myCirclesPopup = SceneType<LiveLocationTacker.MyCirclesPopup>(storyboard: TabBar.self, identifier: "MyCirclesPopup")

    internal static let popupFailedSOS = SceneType<LiveLocationTacker.PopupFailedSOS>(storyboard: TabBar.self, identifier: "PopupFailedSOS")

    internal static let scantoJoinVC = SceneType<LiveLocationTacker.ScantoJoinVC>(storyboard: TabBar.self, identifier: "ScantoJoinVC")

    internal static let sosVC = SceneType<LiveLocationTacker.SosVC>(storyboard: TabBar.self, identifier: "SosVC")

    internal static let splashVC = SceneType<LiveLocationTacker.SplashVC>(storyboard: TabBar.self, identifier: "SplashVC")

    internal static let userDeatilsVC = SceneType<LiveLocationTacker.UserDeatilsVC>(storyboard: TabBar.self, identifier: "UserDeatilsVC")
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
