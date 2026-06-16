//
//  CommonAlertPopup.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 03/09/25.
//

import UIKit

class CommonAlertPopup: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    // MARK: - PROPERTY
    var selectedPopType: CommonAlertPopupType = .Remove_Member
    var clickYesEvent: (() -> ())?
    var clickCancelEvent: (() -> ())?
    var userName: String = ""
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupLocalization() {
        self.lblTitle.text = self.selectedPopType.title
        self.lblSubTitle.text = self.selectedPopType.description
        self.btnYes.backgroundColor = Asset.appMain.color
        self.btnYes.setTitle(L10n.yes, for: .normal)
        self.btnCancel.setTitle(L10n.cancel, for: .normal)
        self.btnCancel.isHidden = true
        
        switch self.selectedPopType {
        case .Remove_Member:
            self.btnCancel.isHidden = false
            break
        case .SOS_Not_Sent:
            self.btnYes.setTitle(L10n.ok, for: .normal)
            self.btnYes.backgroundColor = Asset.appRed.color
            break
        case .SOS_Sent_Successfully:
            self.btnYes.setTitle(L10n.ok, for: .normal)
            break
        case .Leave_without_alert:
            self.btnYes.backgroundColor = Asset.appRed.color
            self.btnCancel.isHidden = false
            break
        case .Alert_Saved:
            self.btnYes.setTitle(L10n.ok, for: .normal)
            break
        case .Delete_Alert:
            self.btnYes.setTitle(L10n.delete, for: .normal)
            self.btnYes.backgroundColor = Asset.appRed.color
            self.btnCancel.isHidden = false
            break
        case .Leave_App:
            self.btnYes.setTitle(L10n.exit, for: .normal)
            self.btnYes.backgroundColor = Asset.appRed.color
            self.btnCancel.isHidden = false
            break
        case .Disable_Child_Mode:
            self.lblSubTitle.text = String(format: self.selectedPopType.description, self.userName)
            self.btnYes.backgroundColor = Asset.appRed.color
            self.btnCancel.setTitle(L10n.no, for: .normal)
            self.btnCancel.isHidden = false
        case .Child_Mode_Disabled:
            self.lblSubTitle.text = String(format: self.selectedPopType.description, self.userName)
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickYes(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.clickYesEvent?()
        }
    }
    
    @IBAction func clickCancel(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.clickCancelEvent?()
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
