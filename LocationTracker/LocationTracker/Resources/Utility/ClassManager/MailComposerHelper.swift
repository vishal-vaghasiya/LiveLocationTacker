//
//  MailComposerHelper.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 11/08/25.
//

import UIKit
import MessageUI

final class MailComposerHelper: NSObject, MFMailComposeViewControllerDelegate {
    
    static let shared = MailComposerHelper()
    
    private override init() { }
    
    func presentFeedbackEmail(from presenter: UIViewController,
                              recipient: String = FeedbackMailID,
                              appName: String = AppName) {
        
        guard MFMailComposeViewController.canSendMail() else {
            print("📭 Mail services are not available.")
            showToast(message: "Mail services are not available.")
            return
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients([recipient])
        mailComposer.setSubject("Feedback for \(appName)")
        mailComposer.setMessageBody("Please provide your feedback here...", isHTML: false)
        
        DispatchQueue.main.async {
            presenter.present(mailComposer, animated: true)
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}
