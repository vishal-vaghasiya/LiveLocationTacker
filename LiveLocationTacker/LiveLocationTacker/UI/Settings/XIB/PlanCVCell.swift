//
//  PlanCVCell.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 01/07/25.
//

import UIKit

class PlanCVCell: UICollectionViewCell {
    @IBOutlet weak var ivSelection: UIImageView!
    
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
    
}
