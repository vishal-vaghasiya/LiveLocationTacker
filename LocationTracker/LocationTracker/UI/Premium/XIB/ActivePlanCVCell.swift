//
//  ActivePlanCVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//

import UIKit

class ActivePlanCVCell: UICollectionViewCell {

    @IBOutlet weak var lblPlanType: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblPlanEndDate: UILabel!
    
    @IBOutlet weak var lblTrial: UILabel!
    @IBOutlet weak var trialStackView: UIStackView!
    
    @IBOutlet weak var lblBillType: UILabel!
    @IBOutlet weak var lblNextPaymentDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var data: PlanStatus! {
        didSet {
            self.lblPlanType.text = data.planDuration
            self.lblPrice.text = data.productPrice
            
            var expiredDate = "-"
            if let date = data.expirationDate {
                expiredDate = formattedDateWithOrdinal(date)
            }
            self.lblPlanEndDate.text = "Plan End on \(expiredDate)"
            
            var freeTrialDate = ""
            if data.isTrial {
                freeTrialDate = "\(data.daysRemaining) Day Left Of Free Trial"
            }
            self.trialStackView.isHidden = !data.isTrial
            self.lblTrial.text = freeTrialDate
            
            var nextPaymentDate = ""
            if let expiry = data.expirationDate {
                let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: expiry)
                nextPaymentDate = formattedDateWithOrdinal(nextDate)
            }
            self.lblNextPaymentDate.text = "Next Payment: \(nextPaymentDate)"
            self.lblBillType.text = data.billType
        }
    }
    
    func formattedDateWithOrdinal(_ date: Date?) -> String {
        guard let validDate = date else {
            return ""
        }
        let day = Calendar.current.component(.day, from: validDate)
        let suffix: String

        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM" // e.g., Dec
        let month = dateFormatter.string(from: validDate)

        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: validDate)

        return "\(month) \(day)\(suffix) \(year)"
    }
    
}
