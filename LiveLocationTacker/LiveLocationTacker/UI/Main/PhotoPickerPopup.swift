//
//  PhotoPickerPopup.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 26/06/25.
//

import UIKit

class PhotoPickerPopup: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var btnTakePhoto: UIEnableDisable!
    @IBOutlet weak var btnGallery: UIEnableDisable!
    
    // MARK: - PROPERTY
    var selectedSourceType:((UIImagePickerController.SourceType)->Void)?
    var cancelClick: (()->Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        btnTakePhoto.isEnabled = true
        btnGallery.isEnabled = true
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func sourceTypeClick(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.selectedSourceType?(UIImagePickerController.SourceType(rawValue: sender.tag)!)
        }
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.cancelClick?()
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
