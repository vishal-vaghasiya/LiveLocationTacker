//
//  AppDelegate.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 29/10/24.
//

import UIKit
import CoreData
//import GoogleMobileAds
import IQKeyboardManagerSwift
//import FacebookCore
//import FBSDKCoreKit
//import FBAudienceNetwork
import FirebaseCore
import CoreLocation
import FirebaseMessaging
import RevenueCat
import FirebaseAuth

//com.phonetracker.familylocator

@main
class AppDelegate: UIResponder, UIApplicationDelegate  {

    let defaults = UserDefaults.standard
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        LocationManager.shared.startMonitoring()
        
        //Google ads
//        GADMobileAds.sharedInstance().start()
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "a733312e1da303c06ba8353d5000c94b" ]
//        
//        FBAudienceNetworkAds.initialize(with: nil, completionHandler: nil)
//        FBAdSettings.setAdvertiserTrackingEnabled(true)
//        AppEvents.activateApp()
//        Settings.isAutoLogAppEventsEnabled = true
//        Settings.isAdvertiserIDCollectionEnabled = true
        
        FirebaseApp.configure()
        PushNotificationManager.shared.requestAuthorization(completionHandler: {
                
        })
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        ConnectionManager.sharedInstance.observeReachability()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        printFonts()
        
        if defaults.string(forKey: "Applanguage") == nil {
            defaults.set("en", forKey: "Applanguage")
        }
        defaults.isArabic()
                
        // Set the back button image globally
        _ = UIImage.SymbolConfiguration(weight: .semibold)
        let backButtonImage = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backButtonImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
        
        // inAppppurchage
//        Purchases.logLevel = .debug
//        Purchases.configure(withAPIKey: Constants.REVANUE_API)
//        Purchases.shared.delegate = self
        RevenueCatManager.shared.configureRevenueCat(userId: nil) // or pass custom user ID
        
//        ApplicationDelegate.shared.application(
//            application,
//            didFinishLaunchingWithOptions: launchOptions
//        )
        
//        _ = BatteryManager.shared  // Initializes and starts monitoring 
        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return Auth.auth().canHandle(url)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("Will Terminate")
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

    func printFonts() {
        for familyName in UIFont.familyNames {
            print("\n-- \(familyName) \n")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print(fontName)
            }
        }
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

    // MARK: - Core Data Saving support -

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension UIViewController {
    
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let storeURL = appDelegate.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url {
            print("Core Data Store Path: \(storeURL)")
        } else {
            print("Unable to retrieve Core Data store path")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func iPadORiPhone(value:CGFloat) -> CGFloat {
        if isIpad() {
            return ((value / 2) * 3)
        }
        return value
    }
}


extension AppDelegate: PurchasesDelegate {

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        print("handle any changes to the user's CustomerInfo")
    }
}


//MARK: - Push Notification Delegate -

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.alert, .badge, .sound])
        } else {
            // Fallback on earlier versions
        }
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
