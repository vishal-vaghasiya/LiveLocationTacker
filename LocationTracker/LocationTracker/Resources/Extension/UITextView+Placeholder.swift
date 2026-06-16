//
//  UITextView+Placeholder.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 13/08/25.
//

import UIKit

final class PlaceholderTextView: UITextView, UITextViewDelegate {

    override var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }

    public var placeholder: String? {
        get {
            (self.viewWithTag(100) as? UILabel)?.text
        }
        set {
            if let label = self.viewWithTag(100) as? UILabel {
                label.text = newValue
                label.sizeToFit()
            } else if let newValue = newValue {
                self.addPlaceholder(newValue)
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }

    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }

    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.font = self.font
        placeholderLabel.textColor = Asset.appDarkGrey.color
        placeholderLabel.tag = 100
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}
