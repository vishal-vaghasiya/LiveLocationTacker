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

//com.phonetracker.familylocator

@main
class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        PushNotificationManager.shared.requestAuthorization(completionHandler: { })
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        ConnectionManager.sharedInstance.observeReachability()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        
        LocationManager.shared.startMonitoring()
        RevenueCatManager.shared.configureRevenueCat(userId: nil) // or pass custom user ID
        _ = BatteryManager.shared  // Initializes and starts monitoring
        
        //Google ads
        //        GADMobileAds.sharedInstance().start()
        //        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "a733312e1da303c06ba8353d5000c94b" ]
        //
        //        FBAudienceNetworkAds.initialize(with: nil, completionHandler: nil)
        //        FBAdSettings.setAdvertiserTrackingEnabled(true)
        //        AppEvents.activateApp()
        //        Settings.isAutoLogAppEventsEnabled = true
        //        Settings.isAdvertiserIDCollectionEnabled = true
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
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
