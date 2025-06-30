//
//  PopupDeleteAccountConfirmation.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 30/06/25.
//

import UIKit

class PopupDeleteAccountConfirmation: UIViewController {

    // MARK: - OUTLET
    
    // MARK: - PROPERTY
    var conformDeleteAction: (() -> Void)?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func yesButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.conformDeleteAction?()
        }
    }
    
    @IBAction func noButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
