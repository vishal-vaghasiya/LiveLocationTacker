//
//  QuickLookManager.swift
//
//  Created by DREAMWORLD on 28/09/24.
//

import Foundation
import QuickLook


class QuickLookManager: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    // Singleton instance
    static let shared = QuickLookManager()
    
    private var previewItems = NSURL()
    
    private override init() {
        super.init()
    }
    
    // Function to present Quick Look
    func presentQuickLook(from viewController: UIViewController, with items: URL) {
        previewItems = items as NSURL
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        
        // Present the QLPreviewController
        viewController.present(previewController, animated: true, completion: nil)
    }
    
    // QLPreviewControllerDataSource Methods
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItems as QLPreviewItem
    }
    
    // Optional: QLPreviewControllerDelegate Methods
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        // Handle any cleanup or actions after dismissal if needed
        print("Quick Look dismissed.")
    }
}
