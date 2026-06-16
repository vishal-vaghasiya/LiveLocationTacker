//
//  AppDelegate.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import FirebaseCore
import FirebaseMessaging
import FirebaseAuth
import FirebaseRemoteConfig
import CoreData
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocationTracker") // Use your .xcdatamodeld filename
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    var remoteConfig: RemoteConfig!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        
        _ = ReachabilityManager.shared  // Starts monitoring
        
//        AppPermissionManager.shared.requestPermission(for: .notification) { isGranded in }
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
//        LocationManager.shared.startMonitoringLocationChanges()
        RevenueCatManager.shared.configureRevenueCat(userId: nil) // or pass custom user ID
        _ = BatteryManager.shared  // Initializes and starts monitoring
        RevenueCatManager.shared.fetchOfferings()
        
        AdManager.shared.resetErrorCount()
        
//        NetworkMonitor.shared.startMonitoring()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNetworkChange),
                                               name: .networkStatusChanged,
                                               object: nil)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return Auth.auth().canHandle(url)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        LocationManager.shared.stopMonitazation()
        LocationManager.shared.startMonitazation()
    }
    
    //MARK: - FIREBASE REMOTE CONFIG
    
    func setupRemoteConfig(completion: @escaping () -> Void) {
        guard ReachabilityManager.shared.isConnectedToNetwork() else {
            showToast(message: "No internet connection")
            completion()
            return
        }
        // Setup Remote Config
        remoteConfig = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // Use 3600 in production
        remoteConfig.configSettings = settings
        
        // Fetch and Activate
        fetchRemoteConfig(completion: completion)
    }
    
    func fetchRemoteConfig(completion: @escaping () -> Void) {
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("❌ Remote config fetch error: \(error.localizedDescription)")
                completion()
                return
            }
            
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                let appConfig = self.remoteConfig["app_config"].jsonValue as? [String:Any] ?? [:]
                
                AdsConfig.startAdsPreference = AdDisplayPreference(caseInsensitive: appConfig["StartAds"] as? String ?? "") ?? .none
                AdsConfig.appOpenAdsPreference = AdDisplayPreference(caseInsensitive: appConfig["AppOpenAds"] as? String ?? "") ?? .none
                AdsConfig.bannerAdsPreference = AdDisplayPreference(caseInsensitive: appConfig["BannerAds"] as? String ?? "") ?? .none
                AdsConfig.interstitialAdsPreference = AdDisplayPreference(caseInsensitive: appConfig["InterstitialAds"] as? String ?? "") ?? .none
                AdsConfig.nativeAdsPreference = AdDisplayPreference(caseInsensitive: appConfig["NativeAds"] as? String ?? "") ?? .none
                AdsConfig.nativeAdsPreLoadPreference = AdDisplayPreference(caseInsensitive: appConfig["NativePreLoadAds"] as? String ?? "") ?? .none
                
                #if DEBUG
                AdsConfig.AppOpenAdId = "ca-app-pub-3940256099942544/5575463023"
                AdsConfig.BannerAdId = "ca-app-pub-3940256099942544/2435281174"
                AdsConfig.InterstitialAdId = "ca-app-pub-3940256099942544/4411468910"
                AdsConfig.NativeAdId = "ca-app-pub-3940256099942544/3986624511"
                #else
                AdsConfig.AppOpenAdId = appConfig["AppOpenAdId"] as? String ?? ""
                AdsConfig.BannerAdId = appConfig["BannerAdId"] as? String ?? ""
                AdsConfig.InterstitialAdId = appConfig["InterstitialAdId"] as? String ?? ""
                AdsConfig.NativeAdId = appConfig["NativeAdId"] as? String ?? ""
                #endif
                
                AdsConfig.InterstitialCountAds = appConfig["InterstitialCountAds"] as?Int ?? 0
                AdsConfig.InterstitialCountShowAds = appConfig["InterstitialCountShowAds"] as? Int ?? 0
                InterstitialAdsManager.shared.interstitialCurrentScreenCount = AdsConfig.InterstitialCountShowAds
                AdsConfig.BannerCountErrorsAds = appConfig["BannerCountErrorsAds"] as? Int ?? 0
                AdsConfig.InterstitialCountErrorsAds = appConfig["InterstitialCountErrorsAds"] as? Int ?? 0
                AdsConfig.NativeCountErrorsAds = appConfig["NativeCountErrorsAds"] as? Int ?? 0
                
                AdManager.shared.loadInterstitialAd()
                
                if AdsConfig.nativeAdsPreLoadPreference == .yes {
                    NativeAdsManager.shared.preloadAds()
                }
                completion()
            }
        }
    }
    
}

//MARK: - Push Notification Delegate -
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        guard !userInfo.isEmpty else { return }
        
        print("📩 PUSH Notification | 🔹Method: \(#function) \n🧾 userInfo: \(userInfo)")
        
        // Extract notification type efficiently
        var notificationType: NotificationType = .none
        if let typeValue = (userInfo[AnyHashable("type")] as? String).flatMap(Int.init) ?? userInfo[AnyHashable("type")] as? Int {
            notificationType = NotificationType(rawValue: typeValue) ?? .none
        }
        
        self.storeNotificationData(userInfo: userInfo, notificationType: notificationType)
        
        if notificationType == .disableChildMode, UIApplication.shared.applicationState == .active {
            showDisableChildModePopup(userInfo: userInfo)
        }
        
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    func showDisableChildModePopup(userInfo: [AnyHashable: Any]) {
        // Make sure this runs on the main thread
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first,
                  let rootVC = window.rootViewController else {
                return
            }
            let name = userInfo[AnyHashable(FirebaseKeys.name)] as? String ?? ""
            let code = userInfo[AnyHashable(FirebaseKeys.code)] as? String ?? ""
            let childNumber = userInfo[AnyHashable(FirebaseKeys.childNumber)] as? String ?? ""
            // Instantiate the view controller
            let popupVC = StoryboardScene.Child.disableRequestPopupVC.instantiate()
            popupVC.userName = name
            
            // Present on top-most view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            popupVC.modalPresentationStyle = .overFullScreen
            topVC.present(popupVC, animated: false, completion:  {
                DefaultManager.NotificationSettings.notificationType = 0
            })
            popupVC.disbleClickEvent = {
                FirebaseManager.shared.removeToChildCircle(from: code, childPhone: childNumber) { isRemove, error in
                    if isRemove {
                        let successVC = StoryboardScene.Circle.commonAlertPopup.instantiate()
                        successVC.selectedPopType = .Child_Mode_Disabled
                        successVC.userName = name
                        successVC.modalPresentationStyle = .overFullScreen
                        topVC.present(successVC, animated: false)
                    }
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if UIApplication.shared.applicationState != .active {
            self.setNotificationTap(userInfo: response.notification.request.content.userInfo)
        }
        completionHandler()
    }
    
    private func storeNotificationData(userInfo: [AnyHashable: Any], notificationType: NotificationType) {
            DefaultManager.NotificationSettings.notificationType = notificationType.rawValue
            DefaultManager.NotificationSettings.userInfo = userInfo
        }
    
    func setNotificationTap(userInfo: [AnyHashable: Any]) {
        guard !userInfo.isEmpty else { return }
        
        // Extract notification type
        var notificationType: NotificationType = .none
        if let typeValue = (userInfo[AnyHashable("type")] as? String).flatMap(Int.init) ?? userInfo[AnyHashable("type")] as? Int {
            notificationType = NotificationType(rawValue: typeValue) ?? .none
        }
        storeNotificationData(userInfo: userInfo, notificationType: notificationType)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
// MARK: - NO INTERNET
    
    @objc func handleNetworkChange() {
        guard let window = UIApplication.shared.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        if let rootVC = window.rootViewController {
            if !NetworkMonitor.shared.isConnected {
                // Show No Internet Screen
                if !(rootVC.presentedViewController is NoInternetVC) {
                    let noInternetVC = NoInternetVC()
                    noInternetVC.modalPresentationStyle = .fullScreen
                    rootVC.present(noInternetVC, animated: true, completion: nil)
                }
            } else {
                // Dismiss if already shown
                if let presentedVC = rootVC.presentedViewController as? NoInternetVC {
                    presentedVC.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
