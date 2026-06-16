//
//  PopupFailedSOS.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 11/08/25.
//

import UIKit

class PopupFailedSOS: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var okayButton: GradientButton!
    
    // MARK: - PROPERTY
    var onDismissed: (() -> Void)?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    // MARK: - UI SETUP
    func setupButton() {
        okayButton.configure(title: "OK", showArrow: false, isEnabled: true)
        okayButton.onTap = {
            self.dismiss(animated: false, completion: {
                self.onDismissed?()
            })
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
