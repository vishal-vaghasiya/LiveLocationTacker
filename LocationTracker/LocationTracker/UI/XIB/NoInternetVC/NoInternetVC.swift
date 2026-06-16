//
//  NoInternetVC.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 08/09/25.
//

import UIKit

class NoInternetVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnRetry: UIButton!
    
    // MARK: - PROPERTY
    
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
        self.btnRetry.setTitle(L10n.retry, for: .normal)
        self.lblTitle.text = L10n.networkError
        self.lblSubTitle.attributedText = L10n.makeSureYouReConnectedToTheInternet.lineSpacing(noOfLine: 3, alignment: .center)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickRetry(_ sender: UIButton) {
        if NetworkMonitor.shared.isConnected {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func clickClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
