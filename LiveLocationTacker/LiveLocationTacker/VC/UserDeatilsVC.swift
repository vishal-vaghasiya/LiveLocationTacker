//
//  UserDeatilsVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 18/11/24.
//

import UIKit

class UserDeatilsVC: UIViewController {

    @IBOutlet weak var main_view: UIView!
    @IBOutlet weak var lbl_number: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_lastupdate: UILabel!
    @IBOutlet weak var lbl_address: UILabel!
    var address = String()
    var username = String()
    var usernumber = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        main_view.makeTopCornerRound(20)
        main_view.addShadow()
        
        lbl_lastupdate.text = formatDate()
        lbl_address.text = address
        lbl_name.text = username
        lbl_number.text = usernumber
    }
    
    @IBAction func outerViewAction(_ sender: UIControl) {
        self.dismiss(animated: true)
    }
}
