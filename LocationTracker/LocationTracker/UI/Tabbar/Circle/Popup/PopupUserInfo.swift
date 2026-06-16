//
//  PopupUserInfo.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit

class PopupUserInfo: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var ivBattery: UIImageView!
    @IBOutlet weak var lblBattery: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    
    @IBOutlet weak var lblAddressTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var lblLastUpdateTitle: UILabel!
    @IBOutlet weak var lblLastupdate: UILabel!
    
    // MARK: - PROPERTY
    var userInfo = UserInfo(dictionary: [:])
    var onDismissed: (() -> Void)?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = getFullName(firstName: userInfo.firstName, lastName: userInfo.lastName)
        self.ivProfile.setImage(urlString: userInfo.profilePic, name: name, placeholderImage: Asset.iconSelectProfile.image, width: self.ivProfile.frame.width * 2, height: self.ivProfile.frame.height * 2)
        
        let value = setUpBattery(batteryLevel: userInfo.batteryLevel)
        self.ivBattery.image = value.2
        self.lblBattery.text = value.0
        self.lblBattery.textColor = value.1
        self.lblName.text = name
        self.lblPhone.text = userInfo.phone
        self.lblLastupdate.text = formatDate()
        self.lblAddress.text = userInfo.address
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top corners only
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        onDismissed?()
    }
    
    // MARK: - UI SETUP
    
    func setupLocalization() {
        self.lblTitle.text = L10n.memberDetail
        self.lblAddressTitle.text = L10n.address + ":"
        self.lblLastUpdateTitle.text = L10n.lastUpdate

    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
