//
//  DisableRequestPopupVC.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 10/09/25.
//

import UIKit

class DisableRequestPopupVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnDisable: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    
    // MARK: - PROPERTY
    var userName: String = ""
    var disbleClickEvent: (() -> ())?
    var rejectClickEvent: (() -> ())?
    
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
        self.lblUserName.text = self.userName
        self.btnDisable.setTitle(L10n.disable, for: .normal)
        self.btnReject.setTitle(L10n.reject, for: .normal)
        self.lblTitle.text = L10n.childModeDisableRequest
        self.lblDescription.attributedText = L10n.hasRequestedToDisableChildModeDoYouWantToApproveThisRequest.lineSpacing(noOfLine: 3, alignment: .left)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickDisable(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.disbleClickEvent?()
        }
    }
    
    @IBAction func clickReject(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.rejectClickEvent?()
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
