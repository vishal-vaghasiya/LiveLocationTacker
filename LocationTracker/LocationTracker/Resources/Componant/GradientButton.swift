//
//  GradientButton.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import Foundation
import UIKit
/*
 @IBOutlet weak var continueButton: GradientButton!
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 continueButton.configure(title: "Continue", showArrow: true, isEnabled: true)
 continueButton.onTap = {
 print("Continue tapped")
 }
 }
 */

class GradientButton: UIView {
    
    // MARK: - Outlets
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var tapButton: UIButton!
    
    // MARK: - Properties
    var onTap: (() -> Void)?
    private var isViewEnabled = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Bundle.main.loadNibNamed("GradientButton", owner: self)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        addSubview(mainView)
        
        tapButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(title: String, showArrow: Bool = true, isEnabled: Bool = true, isDelete: Bool = false) {
        titleLabel.text = title
        arrowImageView.isHidden = !showArrow
        setEnabled(isEnabled, isDelete: isDelete)
    }
    
    func setEnabled(_ enabled: Bool, isDelete: Bool) {
        isViewEnabled = enabled
        tapButton.isUserInteractionEnabled = enabled
        //self.gradientImageView.image = isDelete ? Asset.gradientBgRed.image : enabled ? Asset.gradientBgBlue.image : Asset.gradientBgGray.image
        //self.titleLabel.textColor = isDelete ? Asset.themeRed.color : enabled ? Asset.black.color : Asset.disableButton.color
        //self.arrowImageView.tintColor = isDelete ? Asset.themeRed.color : enabled ? Asset.black.color : Asset.disableButton.color
    }
    
    func hideArrow(_ hide: Bool) {
        arrowImageView.isHidden = hide
    }
    
    // MARK: - Tap Action
    @objc private func handleTap() {
        guard isViewEnabled else { return }
        onTap?()
    }
}
