//
//  UIEnableDisable.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 26/06/25.
//

import UIKit

class UIEnableDisable: UIButton {
    // Define the colors for the enabled and disabled states
    let enabledImage = UIImage(named: "icon_enable_button")
    let disabledImage = UIImage(named: "icon_disable_button")
   
    // Override the isEnabled property to update the background image and state
    override var isEnabled: Bool {
        didSet {
            setBackgroundImage(isEnabled ? enabledImage : disabledImage, for: .normal)
            setBackgroundImage(isEnabled ? enabledImage : disabledImage, for: .disabled)
            alpha = isEnabled ? 1.0 : 1.0
            isUserInteractionEnabled = isEnabled
            clipsToBounds = false
            layer.cornerRadius = 15
            setTitleColor(isEnabled ? .black : .lightGray, for: .normal)
            
            semanticContentAttribute = .forceRightToLeft
        }
    }
 
    private func applyStyle() {
        setBackgroundImage(disabledImage, for: .normal)
        setBackgroundImage(disabledImage, for: .disabled)
        isUserInteractionEnabled = false
        clipsToBounds = false

        imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        setTitleColor(.lightGray, for: .normal)
        setTitleColor(.lightGray, for: .disabled)

        semanticContentAttribute = .forceRightToLeft
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyle()
        self.isEnabled = false
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyStyle()
        self.isEnabled = false
    }
}
