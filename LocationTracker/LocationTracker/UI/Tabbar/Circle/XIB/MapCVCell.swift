//
//  MapCVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit

class MapCVCell: UICollectionViewCell {

    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var radioImageView: UIImageView!
    @IBOutlet weak var lblMapType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var data: MapTypeOption! {
        didSet {
            mapImageView.image = UIImage(named: data.imageName)
            lblMapType.text = data.displayName
        }
    }
    
}
