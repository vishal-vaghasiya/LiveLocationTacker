//
//  PopupFailedSOS.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 30/06/25.
//

import UIKit

class PopupFailedSOS: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var btnOkay: UIEnableDisable!
    
    // MARK: - PROPERTY
    var closePopup:(()->Void)?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        btnOkay.isEnabled = true
    }
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func okayButtonClick(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.closePopup?()
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
