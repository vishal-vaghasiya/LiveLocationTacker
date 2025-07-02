//
//  RevenueCatManager.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 02/07/25.
//

/*
 //MARK: - HOW TO USE
 Configure in AppDelegate / SceneDelegate
 RevenueCatManager.shared.configureRevenueCat(userId: nil) // or pass custom user ID
 */

struct PlanStatus {
    let productId: String
    let expirationDate: Date?
    let isTrial: Bool
    let daysRemaining: Int
}

import Foundation
import RevenueCat

final class RevenueCatManager {
    
    // MARK: - Singleton
    static let shared = RevenueCatManager()
    private let entitlementID = "premium"
    private init() {}
    
    // MARK: - Configure RevenueCat
    func configureRevenueCat(userId: String? = nil) {
#if DEBUG
Purchases.logLevel = .debug
#else
Purchases.logLevel = .error
#endif

        Purchases.configure(withAPIKey: "your_public_api_key", appUserID: userId)
    }
    
    // MARK: - Fetch Offerings
    func fetchOfferings(completion: @escaping (Offering?) -> Void) {
        Purchases.shared.getOfferings { (offerings, error) in
            if let offering = offerings?.current {
                completion(offering)
            } else {
                print("Error fetching offerings: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
    
    // MARK: - Fetch Offerings (Implementation)
    /* RevenueCatManager.shared.fetchOfferings { offering in
        guard let packages = offering?.availablePackages else {
            print("❌ No packages found.")
            return
        }

        for package in packages {
            let product = package.storeProduct

            // Product Info
            let id = product.productIdentifier
            let title = product.localizedTitle
            let description = product.localizedDescription
            let price = product.price
            let localizedPrice = product.localizedPriceString

            // Subscription Info
            let subscriptionPeriod = product.subscriptionPeriod?.unit
            let duration: String
            switch subscriptionPeriod {
            case .day: duration = "Daily"
            case .week: duration = "Weekly"
            case .month: duration = "Monthly"
            case .year: duration = "Yearly"
            default: duration = "One-time"
            }

            print("🟢 Product ID: \(id)")
            print("Title: \(title)")
            print("Description: \(description)")
            print("Price: \(localizedPrice) (\(price))")
            print("Duration: \(duration)\n")
        }
    }*/
    
    // MARK: - Purchase Package
    func purchase(package: Package, completion: @escaping (Bool) -> Void) {
        Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
            if let error = error {
                print("Purchase failed: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if customerInfo?.entitlements.all[self.entitlementID]?.isActive == true {
                print("User has premium access.")
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - Purchase Package (Implementation)
    /* RevenueCatManager.shared.fetchOfferings { offering in
        guard let package = offering?.availablePackages.first else { return }
        
        RevenueCatManager.shared.purchase(package: package) { success in
            if success {
                print("Purchase successful, unlock premium features.")
            } else {
                print("Purchase failed or cancelled.")
            }
        }
    }*/
    
    // MARK: - Check Subscription Status
    func isUserSubscribed(completion: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let isActive = customerInfo?.entitlements.all[self.entitlementID]?.isActive {
                completion(isActive)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - Check Subscription Status (Implementation)
    /* override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        RevenueCatManager.shared.isUserSubscribed { isSubscribed in
            if isSubscribed {
                print("✅ User is subscribed. Show premium content.")
                // Navigate to premium screen or enable features
            } else {
                print("🚫 User is not subscribed. Show paywall.")
                // Present subscription screen
            }
        }
    }*/
    
    // MARK: - Restore Purchases
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                #if DEBUG
                print("Restore failed: \(error.localizedDescription)")
                #endif
            }
            if let isActive = customerInfo?.entitlements.all[self.entitlementID]?.isActive {
                completion(isActive)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - Restore Purchases (Implementation)
    /* @IBAction func restoreButtonTapped(_ sender: UIButton) {
        RevenueCatManager.shared.restorePurchases { success in
            if success {
                print("✅ Restoration successful.")
            } else {
                print("❌ Restoration failed or no active purchases.")
            }
        }
    }*/
    
    // MARK: - Active Subscription Details
    func getCurrentPlanStatus(completion: @escaping (_ info: PlanStatus?) -> Void) {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            guard let customerInfo = customerInfo else {
                print("❌ Failed to get customer info")
                completion(nil)
                return
            }
            
            // Replace "premium" with your actual entitlement identifier
            guard let entitlement = customerInfo.entitlements[self.entitlementID], entitlement.isActive else {
                print("🚫 No active plan")
                completion(nil)
                return
            }
            
            let productId = entitlement.productIdentifier
            let expirationDate = entitlement.expirationDate
            let isTrial = entitlement.willRenew && entitlement.periodType == .intro
            
            var daysRemaining = 0
            if let expiry = expirationDate {
                let components = Calendar.current.dateComponents([.day], from: Date(), to: expiry)
                daysRemaining = components.day ?? 0
            }
            
            let status = PlanStatus(
                productId: productId,
                expirationDate: expirationDate,
                isTrial: isTrial,
                daysRemaining: daysRemaining
            )
            completion(status)
        }
    }
    
    // MARK: - Active Subscription Details (Implementation)
    /* RevenueCatManager.shared.getCurrentPlanStatus { status in
        guard let status = status else {
            print("No active plan.")
            return
        }
        
        print("✅ Plan ID: \(status.productId)")
        
        if let date = status.expirationDate {
            let df = DateFormatter()
            df.dateFormat = "dd MMM yyyy, h:mm a"
            print("📅 Plan expires on: \(df.string(from: date))")
        }
        
        if status.isTrial {
            print("🆓 Trial active — \(status.daysRemaining) days remaining")
        } else {
            print("💳 Next payment in \(status.daysRemaining) days")
        }
    }
     */
    
}
