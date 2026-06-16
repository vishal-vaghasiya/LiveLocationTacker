//
//  ChildModeCircleListCell.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 10/09/25.
//

import UIKit

class ChildModeCircleListCell: UITableViewCell {

    // MARK: - OUTLET
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMember: UILabel!
    
    // MARK: - PROPERTY
    var data: CircleInfo! {
        didSet {
            self.lblName.text = self.data.name
            self.lblMember.text = "\(self.data.members.count) " + (self.data.members.count == 1 ? L10n.member : L10n.members)
        }
    }
    
    // MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - UI SETUP
    func isSelect() {
        self.mainView.borderColor = Asset.appMain.color
    }
    
    func removeSelection() {
        self.mainView.borderColor = Asset.appLightGrey.color
    }
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
