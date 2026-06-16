//
//  PopupChooseOptions.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 06/08/25.
//

import UIKit

class PopupChooseOptions: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var takePhotoButton: GradientButton!
    @IBOutlet weak var chooseFromGalleryButton: GradientButton!
    @IBOutlet weak var cancelButton: GradientButton!
    
    // MARK: - PROPERTY
    var selectedSourceType: ((UIImagePickerController.SourceType) -> Void)?
    var onCancelTapped: (() -> Void)?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    // MARK: - UI SETUP
    func setupButton() {
        takePhotoButton.configure(title: "Take Photo", showArrow: false, isEnabled: true)
        takePhotoButton.onTap = {
            self.selectedSourceType?(.camera)
            self.closePopup()
        }

        chooseFromGalleryButton.configure(title: "Choose From Gallery", showArrow: false, isEnabled: true)
        chooseFromGalleryButton.onTap = {
            self.selectedSourceType?(.photoLibrary)
            self.closePopup()
        }

        cancelButton.configure(title: "Cancel", showArrow: false, isEnabled: true, isDelete: true)
        cancelButton.onTap = {
            self.onCancelTapped?()
            self.closePopup()
        }
    }
    
    private func closePopup() {
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
