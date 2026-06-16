//
//  PopupShareAppFirstTime.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 13/08/25.
//

import UIKit

class PopupShareAppFirstTime: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var shareButton: GradientButton!
    
    // MARK: - PROPERTY
    var onDismissed: (() -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    // MARK: - UI SETUP
    func setupButton() {
        shareButton.configure(title: "Share", showArrow: false, isEnabled: true)
        shareButton.onTap = {
            print(AppURL)
            shareContent(link: AppURL)
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickGotIt(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.onDismissed?()
        }
    }
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
