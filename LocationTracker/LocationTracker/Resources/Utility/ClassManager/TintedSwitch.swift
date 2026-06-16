//
//  TintedSwitch.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit

@IBDesignable
class TintedSwitch: UISwitch {

    @IBInspectable var offTintColor: UIColor = UIColor.lightGray {
        didSet {
            updateColors()
        }
    }

    override var isOn: Bool {
        didSet {
            updateColors()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        updateColors()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateColors()
    }

    @objc private func switchChanged() {
        updateColors()
    }

    private func updateColors() {
        if isOn {
            // Use default or onTintColor
            self.backgroundColor = .clear
            self.layer.cornerRadius = self.frame.height / 2
        } else {
            // Custom OFF tint
            self.backgroundColor = offTintColor
            self.layer.cornerRadius = self.frame.height / 2
        }

        // Ensures the thumb remains visible
        self.clipsToBounds = true
    }
}
