//
//  IntroVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 16/11/24.
//

import UIKit

class IntroVC: UIViewController {

    @IBOutlet weak var lbl_appname: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var termsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnContinue.setButtonTitleAndFunctionality("Continue")
        lbl_appname.text = Constants.APP_NAME
    
        setupTermsTextView()
    }

    @IBAction func btnContinueAction(_ sender: UIButton) {
        self.pushVC(T: OnBoardingVC.instantiate(appStoryboard: .main), viewControllerID: String(describing: OnBoardingVC.self ))
    }
    
    func setupTermsTextView() {
        let text = "by continuing, you confirm that you acknowledge and accept our Privacy Policy and Terms of Use."
        
        let attributedString = NSMutableAttributedString(string: text)
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        let termsRange = (text as NSString).range(of: "Terms of Use")
        
        // Apply links
        attributedString.addAttribute(.link, value: "https://yourdomain.com/privacy-policy", range: privacyRange)
        attributedString.addAttribute(.link, value: "https://yourdomain.com/terms-of-use", range: termsRange)

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
