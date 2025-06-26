//
//  PulseView.swift
//  Sample
//
//  Created by Schaheer Saleem on 1/14/20.
//  Copyright © 2020 Schaheer Saleem. All rights reserved.
//

import UIKit


class PulseView: UIView {
    var staticView: UIView!
    var overlay1: UIView!
    var overlay2: UIView!
    @IBInspectable var color: UIColor = UIColor.red
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubView()
    }
    
    func setupSubView() {
        overlay1 = UIView()
        overlay2 = UIView()
        
        overlay1.backgroundColor = color.withAlphaComponent(0.5)
        overlay2.backgroundColor = color.withAlphaComponent(0.2)
        
        addSubview(overlay1)
        addSubview(overlay2)

        sendSubviewToBack(overlay1)
        sendSubviewToBack(overlay2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlay1.layer.cornerRadius = overlay1.bounds.width / 2
        overlay2.layer.cornerRadius = overlay2.bounds.width / 2
    }
    
    func pulseAnimation() {
        overlay1.removeFromSuperview()
        overlay2.removeFromSuperview()
        setupSubView()
        overlay1.frame = bounds
        overlay2.frame = bounds
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.2
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.5
        
        overlay1.layer.add(pulseAnimation, forKey: "pulse")
        
        let pulseAnimation2 = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation2.duration = 1.2
        pulseAnimation2.autoreverses = true
        pulseAnimation2.repeatCount = .infinity
        pulseAnimation2.fromValue = 1.0
        pulseAnimation2.toValue = 2.00
        
        overlay2.layer.add(pulseAnimation2, forKey: "pulse")
    }
    
    func stopAnimation() {
        overlay1.layer.removeAllAnimations()
        overlay2.layer.removeAllAnimations()
    }
}
