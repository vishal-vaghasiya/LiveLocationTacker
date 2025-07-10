//
//  ProfileVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 19/11/24.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var profile_img: UIImageView!
    @IBOutlet weak var btnUpdate: UIEnableDisable!
    @IBOutlet weak var lbl_number: UILabel!
    @IBOutlet weak var txt_name: UITextField!
    let firebaseManager = FirebaseManager.shared
    var profileURL = String()
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnUpdate.isEnabled = true
        txt_name.text = DefaultManager.User.NAME
        lbl_number.text = DefaultManager.User.PHONE
        profile_img.setImage(urlString: DefaultManager.User.PROFILE_PIC, name: DefaultManager.User.NAME, placeholderImage: Asset.iconDefaultProfile.image, width: profile_img.frame.width * 2, height: profile_img.frame.height * 2)
        
        if DefaultManager.User.GENDER == "Male" {
            btnMale.layer.borderColor = UIColor.btncolor.cgColor
            btnMale.layer.borderWidth = 2
            btnFemale.layer.borderWidth = 0
        } else {
            btnFemale.layer.borderColor = UIColor.btncolor.cgColor
            btnFemale.layer.borderWidth = 2
            btnMale.layer.borderWidth = 0
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func backClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEditimgAction(_ sender: UIButton) {
        let vc = StoryboardScene.Main.photoPickerPopup.instantiate()
        vc.selectedSourceType = { (type) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = type
            imagePickerController.allowsEditing = true
            DispatchQueue.main.async {
                self.present(imagePickerController, animated: true)
            }
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @IBAction func btnEditNameClick(_ sender: UIButton) {
        self.txt_name.isUserInteractionEnabled = true
        self.txt_name.becomeFirstResponder()
    }
    
    @IBAction func btnUpdateProfileAction(_ sender: UIButton) {
        if sender.tag == 0 {
            btnMale.layer.borderColor = UIColor.btncolor.cgColor
            btnMale.layer.borderWidth = 2
            btnFemale.layer.borderWidth = 0
        } else {
            btnFemale.layer.borderColor = UIColor.btncolor.cgColor
            btnFemale.layer.borderWidth = 2
            btnMale.layer.borderWidth = 0
        }
    }
    
    @IBAction func btnDeleteAccount(_ sender: UIButton) {
        let vc = StoryboardScene.Settings.popupDeleteAccountConfirmation.instantiate()
        vc.conformDeleteAction = {
            self.showLoader(text: "Deleting...")
            
            DefaultManager.removeAll()
            
            self.firebaseManager.deleteUserAccount(userPhoneNumber: self.lbl_number.text ?? "") { success in
                self.hideLoader()
                if success {
                    self.navigateToOnboarding()
                } else {
                    self.showAlert(title: "Error", message: "Something went wrong. Please try again later.")
                }
            }
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton) {
        showLoader(text: "Updating...")
//        firebaseManager.updateUserNameInFirebase(userPhonenumber: lbl_number.text ?? "", entername: txt_name.text ?? "") { updated, errorMessage in
//            self.hideLoader()
//            self.txt_name.isUserInteractionEnabled = false
//            if updated {
//                DefaultManager.User.NAME = self.txt_name.text ?? ""
//                DefaultManager.User.GENDER = self.btnMale.layer.borderWidth == 2 ? "Male" : "Female"
//                
//                let vc = StoryboardScene.Settings.popupProfileUpdateSuccess.instantiate()
//                vc.closePopup = {
//                    self.navigationController?.popViewController(animated: true)
//                }
//                vc.modalPresentationStyle = .overCurrentContext
//                self.present(vc, animated: false)
//            } else {
//                self.showAlert(title: "", message: errorMessage ?? "")
//            }
//        }
        
        let updatedData: [String: Any] = [
            FirebaseKeys.name: txt_name.text ?? "",
            FirebaseKeys.gender: self.btnMale.layer.borderWidth == 2 ? "Male" : "Female",
            FirebaseKeys.profilePicture: profileURL
        ]

        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.firebaseManager.updateUserData(updatedValues: updatedData) { success, message in
                self.showToastMessage(message)
                self.hideLoader()
            }
        })
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // This method gets called when the user selects an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        var selectedImage = UIImage()
        if let editedImage = info[.editedImage] as? UIImage {
            print("Selected edited image: \(editedImage)")
            selectedImage = editedImage
            profile_img.image = selectedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            print("Selected original image: \(originalImage)")
            selectedImage = originalImage
            profile_img.image = originalImage
        }
        DefaultManager.User.PROFILE_DATA = profile_img.image?.pngData() ?? Data()
        firebaseManager.uploadProfileImage(selectedImage) { result in
            switch result {
            case .success(let url):
                self.profileURL = url.absoluteString
                //                updateUserProfile(with: url) { error in
                //                    if let error = error {
                //                        print("Profile update failed: \(error)")
                //                    } else {
                //                        print("Profile updated successfully!")
                //                    }
                //                }
                break
            case .failure(let error):
                print("Upload failed: \(error)")
            }
        }
    }
    
    // This method gets called when the user cancels the picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        print("Image picker cancelled")
    }
}
