//
//  PrimaryButton.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 02/09/25.
//

import UIKit

class PrimaryButton: UIButton {
    
    // Colors
    private let enabledColor = Asset.appMain.color
    private let disabledColor = Asset.appLightGrey.color
    private let enabledTextColor = Asset.appWhite.color
    private let disabledTextColor = Asset.appDarkGrey.color
    private let enableShadowColor = Asset.appShadowBlue.color.cgColor
    
    override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 10
        titleLabel?.font = FontFamily.Poppins.medium.font(size: 16)
        setTitleColor(enabledColor, for: .normal)
        updateAppearance()
    }
    
    private func updateAppearance() {
        backgroundColor = isEnabled ? enabledColor : disabledColor
        setTitleColor(isEnabled ? enabledTextColor : disabledTextColor, for: .normal)
        if isEnabled {
            layer.shadowColor = enableShadowColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0, height: 5)
            layer.shadowRadius = 4
        } else {
            layer.shadowOpacity = 0
        }
    }

}
