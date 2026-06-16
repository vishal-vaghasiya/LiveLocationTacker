//
//  PopupDeleteAccountConfirmation.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 11/08/25.
//

import UIKit

class PopupDeleteAccountConfirmation: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var yashButton: GradientButton!
    
    // MARK: - PROPERTY
    var conformDeleteAction: (() -> Void)?
    var noClickAction: (() -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    // MARK: - UI SETUP
    func setupButton() {
        yashButton.configure(title: "Yes", showArrow: false, isEnabled: true)
        yashButton.onTap = {
            self.dismiss(animated: false) {
                self.conformDeleteAction?()
            }
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func noButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.noClickAction?()
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
