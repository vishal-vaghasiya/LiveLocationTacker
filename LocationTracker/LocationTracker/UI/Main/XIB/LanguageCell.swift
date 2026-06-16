//
//  LanguageCell.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 02/09/25.
//

import UIKit

class LanguageCell: UITableViewCell {

    // MARK: - OUTLET
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLung: UILabel!
    
    // MARK: - PROPERTY
    
    var languageData: LanguageType! {
        didSet {
            self.imgFlag.image = self.languageData.icon
            self.lblName.text = self.languageData.value
            self.lblLung.text = "(\(self.languageData.languageText))"
        }
    }
    
    // MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - UI SETUP
    
    func isSelect() {
        self.mainView.backgroundColor = Asset.appMain.color
        self.mainView.borderColor = .clear
        self.lblName.textColor = Asset.appWhite.color
        self.lblLung.textColor = Asset.appWhite.color
    }
    
    func removeSelection() {
        self.mainView.backgroundColor = Asset.appWhite.color
        self.mainView.borderColor = Asset.appLightGrey.color
        self.mainView.borderWidth = 1
        self.lblName.textColor = Asset.appBlack.color
        self.lblLung.textColor = Asset.appDarkGrey.color
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
