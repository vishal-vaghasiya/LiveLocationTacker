//
//  SplashVC.swift
//
//  Created by DREAMWORLD on 13/09/24.
//

import UIKit
import ProgressHUD
import NVActivityIndicatorView
class SplashVC: UIViewController {
    
    @IBOutlet weak var vwActivity: NVActivityIndicatorView!
    
    var isFirstAdsFailed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoader()
        
        guard reachability.connection != .unavailable else {
            self.navigateToHome()
            return
        }
        
        self.navigateToHome()
    }
    
    func showLoader() {
        vwActivity.type = .lineSpinFadeLoader
        vwActivity.padding = 4.0
        vwActivity.color = .button_color
        vwActivity.startAnimating()
    }
}
