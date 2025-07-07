//
//  IntroVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 16/11/24.
//

import UIKit

class IntroVC: UIViewController {

    @IBOutlet weak var lbl_appname: UILabel!
    @IBOutlet weak var btnContinue: UIEnableDisable!
    @IBOutlet weak var termsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnContinue.isEnabled = true
        lbl_appname.text = APP_NAME
    
        setupTermsTextView()
    }

    @IBAction func btnContinueAction(_ sender: UIButton) {
        let vc = StoryboardScene.Main.onBoardingVC.instantiate()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupTermsTextView() {
        let text = "by continuing, you confirm that you acknowledge and accept our Privacy Policy and Terms of Use."
        
        let attributedString = NSMutableAttributedString(string: text)
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        let termsRange = (text as NSString).range(of: "Terms of Use")
        
        // Apply links
        attributedString.addAttribute(.link, value: PRIVACY, range: privacyRange)
        attributedString.addAttribute(.link, value: TERMS, range: termsRange)

        // Set font and style
        attributedString.addAttribute(.font, value: UIFont(name: "Poppins-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12), range: NSMakeRange(0, text.count))

        termsTextView.attributedText = attributedString
        termsTextView.isEditable = false
        termsTextView.isSelectable = true
        termsTextView.isScrollEnabled = false
        termsTextView.dataDetectorTypes = [.link]
        termsTextView.textColor = .gray
        termsTextView.textAlignment = .center
        termsTextView.linkTextAttributes = [
            .foregroundColor: UIColor.gray,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
}
