//
//  PopupEnableChildmode.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 02/07/25.
//

import UIKit

class PopupEnableChildmode: UIViewController {

    // MARK: - OUTLET
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func closeButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func disableClick(_ sender: UIButton) {
        let vc = StoryboardScene.ChildMode.popupRequestToDisable.instantiate()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
