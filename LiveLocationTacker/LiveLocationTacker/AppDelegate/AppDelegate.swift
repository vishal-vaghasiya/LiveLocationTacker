//
//  AppDelegate.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 29/10/24.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import FirebaseCore
import CoreLocation
import FirebaseMessaging
import RevenueCat
import FirebaseAuth
import FirebaseRemoteConfig

@main
class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    var remoteConfig: RemoteConfig!
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
//        AdsManager.shared.loadInterstitialAd()
        
        PushNotificationManager.shared.requestAuthorization(completionHandler: { })
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        ConnectionManager.sharedInstance.observeReachability()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        
        LocationManager.shared.startMonitoringLocationChanges()
        RevenueCatManager.shared.configureRevenueCat(userId: nil) // or pass custom user ID
        _ = BatteryManager.shared  // Initializes and starts monitoring
        RevenueCatManager.shared.fetchOfferings()

        AdManager.shared.resetErrorCount()
        return true
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
                
                AdsConfig.AppOpenAdId = appConfig["AppOpenAdId"] as? String ?? ""
                
                AdsConfig.BannerAdId = appConfig["BannerAdId"] as? String ?? ""
                AdsConfig.BannerCountErrorsAds = appConfig["BannerCountErrorsAds"] as? Int ?? 0
                
                AdsConfig.InterstitialAdId = appConfig["InterstitialAdId"] as? String ?? ""
                AdsConfig.InterstitialCountAds = appConfig["InterstitialCountAds"] as?Int ?? 0
                AdsConfig.InterstitialCountErrorsAds = appConfig["InterstitialCountErrorsAds"] as? Int ?? 0
                AdsConfig.InterstitialCountShowAds = appConfig["InterstitialCountShowAds"] as? Int ?? 0
                InterstitialAdsManager.shared.interstitialCurrentScreenCount = AdsConfig.InterstitialCountShowAds
                
                AdsConfig.NativeAdId = appConfig["NativeAdId"] as? String ?? ""
                AdsConfig.NativeCountErrorsAds = appConfig["NativeCountErrorsAds"] as? Int ?? 0
                
                AdManager.shared.loadInterstitialAd()
                
                /*if AdsConfig.nativeAdsPreLoadPreference == .yes {
                    NativeAdsManager.shared.preloadAds()
                }*/
                completion()
            }
        }
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
    
    // MARK: - Core Data stack -
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SecureVaultDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
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
        
        if notificationType == .disableChildMode {
            showDisableChildModePopup()
        }
        
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    func showDisableChildModePopup() {
        // Make sure this runs on the main thread
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first,
                  let rootVC = window.rootViewController else {
                return
            }
            
            // Instantiate the view controller
            let popupVC = StoryboardScene.ChildMode.popupInviteChildMode.instantiate()
            
            // Present on top-most view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            popupVC.modalPresentationStyle = .fullScreen
            topVC.present(popupVC, animated: true, completion:  {
                DefaultManager.NotificationSettings.notificationType = 0
            })
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
        print(error)
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
