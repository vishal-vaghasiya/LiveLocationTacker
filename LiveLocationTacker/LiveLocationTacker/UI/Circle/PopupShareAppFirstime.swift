//
//  PopupShareAppFirstime.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 30/06/25.
//

import UIKit

class PopupShareAppFirstime: UIViewController {

    // MARK: - OUTLET
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickShare(_ sender: UIButton) {
        self.share(message: "", link: APP_URL)
    }
    
    @IBAction func clickGotIt(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
