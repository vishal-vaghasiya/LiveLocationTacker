//
//  SetProfilePicVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 11/09/25.
//

import UIKit

class SetProfilePicVC: UIViewController, RotationRulerViewDelegate {

    // MARK: - OUTLET
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var ruler: RotationRulerView!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDone: PrimaryButton!
    // MARK: - PROPERTY
    var didFinishCropping: ((UIImage) -> Void)?
    var selectedImage = UIImage()
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.image = selectedImage
        ruler.delegate = self
        ruler.onValueChanged = { [weak self] radians in
            self?.profileImageView.transform = CGAffineTransform(rotationAngle: radians)
        }
        setNativeAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupLocalization() {
        self.lblTitle.text = L10n.setProfilePic
        self.btnCancel.setTitle(L10n.cancel, for: .normal)
        self.btnDone.setTitle(L10n.done, for: .normal)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func doneButtonClick(_ sender: PrimaryButton) {
        guard let image = profileImageView.image else { return }

        // Create renderer with imageView’s size
        let renderer = UIGraphicsImageRenderer(size: profileImageView.bounds.size)
        let rotatedImage = renderer.image { ctx in
            // Move origin to center
            ctx.cgContext.translateBy(x: profileImageView.bounds.midX,
                                      y: profileImageView.bounds.midY)
            
            // Apply current transform (rotation)
            ctx.cgContext.concatenate(profileImageView.transform)
            
            // Move back
            ctx.cgContext.translateBy(x: -profileImageView.bounds.midX,
                                      y: -profileImageView.bounds.midY)
            
            // Draw the original image into the rotated context
            image.draw(in: profileImageView.bounds)
        }

        // 👉 Send the truly rotated image back
        didFinishCropping?(rotatedImage)
        dismiss(animated: false)
    }
    
    // MARK: - OTHER
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    func rotationRuler(_ ruler: RotationRulerView, didChangeValue value: CGFloat) {
        print("Rotation: \(value)°")
    }
}
