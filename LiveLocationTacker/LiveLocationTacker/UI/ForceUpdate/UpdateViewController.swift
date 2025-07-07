//
//  UpdateViewController.swift
//
//  Created by DREAMWORLD on 09/09/23.
//

import UIKit

class UpdateViewController: UIViewController {

    @IBOutlet weak var btnUpdate: UIEnableDisable!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnUpdate.isEnabled = true
    }

    @IBAction func btnUpdateClicked(_ sender: UIButton) {
        if let url = URL(string: APP_URL) {
            UIApplication.shared.open(url)
        }
    }

}
