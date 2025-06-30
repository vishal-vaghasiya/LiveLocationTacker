//
//  PopupProfileUpdateSuccess.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 30/06/25.
//

import UIKit

class PopupProfileUpdateSuccess: UIViewController {

    // MARK: - OUTLET
    
    // MARK: - PROPERTY
    var closePopup: (() -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func okayButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.closePopup?()
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
