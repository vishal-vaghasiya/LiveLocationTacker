//
//  ChildModeAddMemberCell.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 09/09/25.
//

import UIKit

class ChildModeAddMemberCell: UITableViewCell {

   
    // MARK: - OUTLET
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCricle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var sepretorView: UIView!
    
    // MARK: - PROPERTY
    var addClickEvent: (() -> ())?
    var removeClickEvent: (() -> ())?
    
    var data: UserInfo! {
        didSet {
            let name = getFullName(firstName: data.firstName, lastName: data.lastName)
            imgProfile.setImage(urlString: data.profilePic, name: name, placeholderImage: Asset.iconSelectProfile.image, width: imgProfile.frame.width * 2, height: imgProfile.frame.height * 2)
            lblUserName.text = name
        }
    }
    
    // MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    @IBAction func clickAdd(_ sender: UIButton) {
        self.addClickEvent?()
    }
    
    @IBAction func clickRemove(_ sender: UIButton) {
        self.removeClickEvent?()
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
