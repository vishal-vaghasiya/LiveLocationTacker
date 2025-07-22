//
//  PlanCVCell.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 01/07/25.
//

import UIKit
import RevenueCat

class PlanCVCell: UICollectionViewCell {
    @IBOutlet weak var ivSelection: UIImageView!
    
    @IBOutlet weak var freeTrialView: UIView!
    @IBOutlet weak var lblTrialDuration: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var lblPlanDuration: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblPricePerMonth: UILabel!
    
    @IBOutlet weak var ivLocation: UIImageView!
    @IBOutlet weak var ivNotification: UIImageView!
    @IBOutlet weak var ivBattery: UIImageView!
    @IBOutlet weak var ivNoAds: UIImageView!
    
    override var isHighlighted: Bool {
        didSet {
            // Prevent visual changes when highlighted
            contentView.alpha = 1.0
            ivSelection.alpha = 1.0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ivSelection.isHighlighted = false
    }
    
    var data: Package! {
     didSet {
         let product = data.storeProduct
         let price = product.price as NSDecimalNumber
         let formatter = product.priceFormatter ?? NumberFormatter()
         if formatter.currencyCode == nil {
             formatter.numberStyle = .currency
             formatter.locale = Locale.current
         }

         // Subscription Info
         let subscription = product.subscriptionPeriod
         let duration: String
         var perMonthPriceText = ""
         
         // Set duration label
         switch subscription?.unit {
         case .week:
             duration = "Weekly"
             // Convert to monthly price: approx 4.345 weeks per month
             let perMonthPrice = price.multiplying(by: 4.345)
             perMonthPriceText = formatter.string(from: perMonthPrice) ?? ""
             
         case .month:
             duration = "Monthly"
             perMonthPriceText = formatter.string(from: price) ?? ""

         case .year:
             duration = "Yearly"
             // Divide by 12 months
             let perMonthPrice = price.dividing(by: 12)
             perMonthPriceText = formatter.string(from: perMonthPrice) ?? ""

         default:
             duration = "One-time"
             perMonthPriceText = formatter.string(from: price) ?? ""
         }
         
         if let intro = product.introductoryDiscount,
            intro.paymentMode == .freeTrial {

             self.freeTrialView.isHidden = false
             let unit = intro.subscriptionPeriod.unit
             let value = intro.subscriptionPeriod.value

             let unitString: String
             switch unit {
             case .day: unitString = value == 1 ? "Day" : "Days"
             case .week: unitString = value == 1 ? "Week" : "Weeks"
             case .month: unitString = value == 1 ? "Month" : "Months"
             case .year: unitString = value == 1 ? "Year" : "Years"
             @unknown default: unitString = "Days"
             }

             self.lblTrialDuration.text = "\(value) \(unitString) Free"
         } else {
             self.freeTrialView.isHidden = true
             self.lblTrialDuration.text = ""
         }
         
         self.lblPlanDuration.text = duration
         self.lblPrice.text = formatter.string(from: price) ?? ""
         self.lblPricePerMonth.text = "\(perMonthPriceText)/Monthly"
        }
    }
}
