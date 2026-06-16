//
//  AddressTypeCVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 03/09/25.
//

import UIKit

class AddressTypeCVCell: UICollectionViewCell {

    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var data: AddressType! {
        didSet {
            ivIcon.image = UIImage(named: data.icon)
            lblName.text = data.name
        }
    }
}
