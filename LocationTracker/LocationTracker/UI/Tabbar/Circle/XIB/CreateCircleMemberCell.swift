//
//  CreateCircleMemberCell.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 03/09/25.
//

import UIKit

class CreateCircleMemberCell: UITableViewCell {
    
    // MARK: - OUTLET
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    
    // MARK: - PROPERTY
    var clickCloseEvent: (() -> ())?
    
    // MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - UI SETUP
    var data: UserInfo! {
        didSet {
            let name = getFullName(firstName: data.firstName, lastName: data.lastName)
            self.lblName.text = name
            self.lblAddress.text = data.address
            self.imgProfile.setImage(urlString: data.profilePic, name: name, placeholderImage: Asset.iconDefaultProfile.image, width: self.imgProfile.frame.width * 2, height: self.imgProfile.frame.height * 2)
        }
    }
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickClose(_ sender: UIButton) {
        self.clickCloseEvent?()
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
