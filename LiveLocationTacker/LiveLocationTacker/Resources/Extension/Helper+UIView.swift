//
//  Helper+UIView.swift
//  LiveLocationTacker
//
//  Created by Nexios Mac 4 on 14/07/25.
//

import Foundation
import UIKit

public extension UIView {
    @IBInspectable var topLeftCorner: CGFloat {
        get { return 0 } // Not retrievable
        set { applyCornerRadius(corner: .layerMinXMinYCorner, radius: newValue) }
    }
    
    @IBInspectable var topRightCorner: CGFloat {
        get { return 0 }
        set { applyCornerRadius(corner: .layerMaxXMinYCorner, radius: newValue) }
    }
    
    @IBInspectable var bottomLeftCorner: CGFloat {
        get { return 0 }
        set { applyCornerRadius(corner: .layerMinXMaxYCorner, radius: newValue) }
    }
    
    @IBInspectable var bottomRightCorner: CGFloat {
        get { return 0 }
        set { applyCornerRadius(corner: .layerMaxXMaxYCorner, radius: newValue) }
    }
    
    private func applyCornerRadius(corner: CACornerMask, radius: CGFloat) {
        // Add existing masked corners
        layer.maskedCorners.insert(corner)
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}
