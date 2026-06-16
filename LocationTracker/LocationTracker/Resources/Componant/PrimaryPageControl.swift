//
//  PrimaryPageControl.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 02/09/25.
//

import UIKit

class PrimaryPageControl: UIStackView {
    
    var numberOfPages: Int = 0 {
        didSet { setupDots() }
    }
    
    var currentPage: Int = 0 {
        didSet { updateDots() }
    }
    
    private var dots: [UIView] = []
    
    // Customizable colors
    var activeColor: UIColor = Asset.appMain.color
    var inactiveColor: UIColor = Asset.appMain.color
    
    // Sizes
    private let inactiveSize: CGFloat = 12
    private let activeWidth: CGFloat = 24
    private let height: CGFloat = 12
    
    init() {
        super.init(frame: .zero)
        axis = .horizontal
        spacing = 8
        alignment = .center
        distribution = .equalSpacing
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        axis = .horizontal
        spacing = 8
        alignment = .center
        distribution = .equalSpacing
    }
    
    private func setupDots() {
        // Clear existing
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()
        
        for _ in 0..<numberOfPages {
            let dot = UIView()
            dot.layer.cornerRadius = height / 2
            dot.layer.borderWidth = 1.5
            dot.layer.borderColor = inactiveColor.cgColor
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: inactiveSize).isActive = true
            dot.heightAnchor.constraint(equalToConstant: height).isActive = true
            
            addArrangedSubview(dot)
            dots.append(dot)
        }
        updateDots()
    }
    
    private func updateDots() {
        for (index, dot) in dots.enumerated() {
            if index == currentPage {
                // Active page
                dot.backgroundColor = activeColor
                dot.layer.borderColor = activeColor.cgColor
                dot.constraints.first { $0.firstAttribute == .width }?.constant = activeWidth
            } else {
                // Inactive pages
                dot.backgroundColor = .clear
                dot.layer.borderColor = inactiveColor.cgColor
                dot.constraints.first { $0.firstAttribute == .width }?.constant = inactiveSize
            }
        }
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
}
