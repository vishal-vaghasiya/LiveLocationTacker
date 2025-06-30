//
//  MapTypeCVCell.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 30/06/25.
//

import UIKit

class MapTypeCVCell: UICollectionViewCell {
    
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var radioImageView: UIImageView!
    @IBOutlet weak var lblMapType: UILabel!
    @IBOutlet weak var nameView: UIView!
    
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
