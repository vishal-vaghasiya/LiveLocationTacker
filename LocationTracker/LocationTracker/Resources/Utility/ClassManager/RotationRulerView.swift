//
//  RotationRulerView.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 11/09/25.
//

import UIKit
import AudioToolbox
import CoreHaptics

protocol RotationRulerViewDelegate: AnyObject {
    func rotationRuler(_ ruler: RotationRulerView, didChangeValue value: CGFloat)
}

class RotationRulerView: UIView, UIScrollViewDelegate {
    
    weak var delegate: RotationRulerViewDelegate?
    var onValueChanged: ((CGFloat) -> Void)?
    
    private let scrollView = UIScrollView()
    private let valueLabel = UILabel()
    private let centerIndicator = UIView()
    
    private let minValue: CGFloat = -45
    private let maxValue: CGFloat = 45
    private let step: CGFloat = 1 // degree per tick
    private let tickSpacing: CGFloat = 10
    
    private var totalTicks: Int {
        return Int((maxValue - minValue) / step)
    }

    private var lastPlayedValue: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // ScrollView
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
        
        // Value Label
        valueLabel.font = UIFont.boldSystemFont(ofSize: 18)
        valueLabel.textAlignment = .center
        valueLabel.text = "0°"
        lastPlayedValue = 0
        addSubview(valueLabel)
        
        // Center Indicator
        centerIndicator.backgroundColor = Asset.appMain.color
        addSubview(centerIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 30)
        valueLabel.frame = CGRect(x: 0, y: bounds.height - 30, width: bounds.width, height: 30)
        centerIndicator.frame = CGRect(x: bounds.midX - 1, y: 0, width: 2, height: scrollView.bounds.height)
        
        setupTicks()
    }
    
    private func setupTicks() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let rulerHeight = scrollView.bounds.height
        var x: CGFloat = bounds.width / 2 // start with offset
        
        for i in 0...totalTicks {
            let tick = UIView(frame: CGRect(x: x, y: rulerHeight/2 - 15, width: 1, height: 30))
            tick.backgroundColor = .darkGray
            scrollView.addSubview(tick)
            
            if i % 5 == 0 { // bigger tick every 5 steps
                tick.frame.size.height = 40
                tick.frame.origin.y = rulerHeight/2 - 20
            }
            
            x += tickSpacing
        }
        
        scrollView.contentSize = CGSize(width: x + bounds.width / 2, height: rulerHeight)
        scrollView.contentOffset = CGPoint(x: (scrollView.contentSize.width - bounds.width)/2, y: 0) // start at 0°
        valueLabel.text = "0°"
        lastPlayedValue = 0
        // Notify delegate and closure of default value
        let defaultValue: CGFloat = 0
        delegate?.rotationRuler(self, didChangeValue: defaultValue)
        onValueChanged?(defaultValue * .pi / 180)
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x + bounds.width / 2
        let value = minValue + (offsetX / tickSpacing) * step
        
        let clamped = max(minValue, min(maxValue, value))
        let degree = Int(clamped)
        valueLabel.text = "\(degree)°"
        if degree != lastPlayedValue {
            AudioServicesPlaySystemSound(1104) // system tick sound
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            lastPlayedValue = degree
        }
        delegate?.rotationRuler(self, didChangeValue: clamped)
        onValueChanged?(clamped * .pi / 180) // radians
    }
    
    /// Reset to 0°
    func reset() {
        let centerOffset = (scrollView.contentSize.width - bounds.width) / 2
        scrollView.setContentOffset(CGPoint(x: centerOffset, y: 0), animated: true)
    }
}
