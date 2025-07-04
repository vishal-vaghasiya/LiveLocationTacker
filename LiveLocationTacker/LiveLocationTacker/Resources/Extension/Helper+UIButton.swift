//
//  Helper+UIButton.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 04/07/25.
//

import UIKit

extension UIButton {
    func setButtonTitleAndFunctionality(_ name: String,
                                        cornerRadiues: Double = isIpad() ? 30 : 15,
                                        titleColor: UIColor = .black,
                                        backColor: UIColor = .mainColor,
                                        backgroundImage: UIImage? = UIImage(named: "btn_bg"),
                                        textFont: UIFont? = AppFont.semiBold(size: isIpad() ? 24 : 18),
                                        lottieAnimationName: String? = nil,
                                        isShowLottieWithTitle: Bool = false,
                                        animationViewWidth: CGFloat = 30,
                                        animationViewHight: CGFloat = 30) {
        
        // Create attributed string with image
        let fullString = NSMutableAttributedString()
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: titleColor
        ]
        let title = NSAttributedString(string: "\(name)  ", attributes: titleAttributes)
        fullString.append(title)
        
        let arrowImage = UIImage(named: "icon_arrow_next")
        let attachment = NSTextAttachment()
        attachment.image = arrowImage
        attachment.bounds = CGRect(x: 0, y: (textFont?.descender ?? -4), width: 12, height: 21)
        fullString.append(NSAttributedString(attachment: attachment))
        
        self.setAttributedTitle(fullString, for: .normal)
        self.setBackgroundImage(backgroundImage, for: .normal)
        self.layer.cornerRadius = CGFloat(cornerRadiues)
        self.clipsToBounds = true
        self.layoutIfNeeded()
    }
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.1
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity   = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
    }
}
