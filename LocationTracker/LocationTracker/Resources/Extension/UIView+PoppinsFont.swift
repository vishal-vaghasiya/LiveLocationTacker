//
//  UIView+PoppinsFont.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit

/// Protocol that allows UIViews to apply a custom font
protocol FontApplicable {
    func applyFont(named name: String, size: CGFloat)
}

/// Default implementation for UILabel, UITextField, UIButton, UITextView
extension FontApplicable where Self: UIView {
    func applyFont(named name: String, size: CGFloat) {
        guard let font = UIFont(name: name, size: size) else {
            print("⚠️ Font '\(name)' not found. Make sure it's added to the project and Info.plist.")
            return
        }

        switch self {
        case let label as UILabel:
            label.font = font
        case let textField as UITextField:
            textField.font = font
        case let button as UIButton:
            button.titleLabel?.font = font
        case let textView as UITextView:
            textView.font = font
        default:
            break
        }
    }
}

// MARK: - Conform UI Components to FontApplicable
extension UILabel: FontApplicable {}
extension UITextField: FontApplicable {}
extension UIButton: FontApplicable {}
extension UITextView: FontApplicable {}

/// MARK: - IBInspectable support for Poppins fonts
extension UIView {

    @IBInspectable var fontRegular: CGFloat {
        set { setPoppinsFont(FontFamily.Poppins.regular.name, size: newValue) }
        get { return 0.0 }
    }

    @IBInspectable var fontMedium: CGFloat {
        set { setPoppinsFont(FontFamily.Poppins.medium.name, size: newValue) }
        get { return 0.0 }
    }

    @IBInspectable var fontSemiBold: CGFloat {
        set { setPoppinsFont(FontFamily.Poppins.semiBold.name, size: newValue) }
        get { return 0.0 }
    }

    @IBInspectable var fontBold: CGFloat {
        set { setPoppinsFont(FontFamily.Poppins.bold.name, size: newValue) }
        get { return 0.0 }
    }
    
    @IBInspectable var fontItalic: CGFloat {
        set { setPoppinsFont(FontFamily.Poppins.italic.name, size: newValue) }
        get { return 0.0 }
    }

    /// Internal method to apply a selected Poppins font style
    private func setPoppinsFont(_ fontName: String, size: CGFloat) {
        (self as? FontApplicable)?.applyFont(named: fontName, size: size)
    }
}
