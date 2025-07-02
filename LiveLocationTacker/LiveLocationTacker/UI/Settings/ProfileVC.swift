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
    let firebaseManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnUpdate.isEnabled = true
        txt_name.text = Constants.USERDEFAULTS.getCurrentuserName()
        lbl_number.text = Constants.USERDEFAULTS.getCurrentuserNumber()
        profile_img.image = UIImage(data: Constants.USERDEFAULTS.getProfileImage() ?? Data())
        
        if Constants.USERDEFAULTS.getCurrentuserGender() == "Male" {
            btnMale.layer.borderColor = UIColor.btncolor.cgColor
            btnMale.layer.borderWidth = 2
            btnFemale.layer.borderWidth = 0
        } else {
            btnFemale.layer.borderColor = UIColor.btncolor.cgColor
            btnFemale.layer.borderWidth = 2
            btnMale.layer.borderWidth = 0
        }
    }
    
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
        }
        else{
            btnFemale.layer.borderColor = UIColor.btncolor.cgColor
            btnFemale.layer.borderWidth = 2
            btnMale.layer.borderWidth = 0
        }
    }
    
    @IBAction func btnDeleteAccount(_ sender: UIButton) {
        let vc = StoryboardScene.Settings.popupDeleteAccountConfirmation.instantiate()
        vc.conformDeleteAction = {
            self.showLoader(text: "Deleting...")
            
            Constants.USERDEFAULTS.removeObject(forKey: "isIntro")
            Constants.USERDEFAULTS.removeCurrentUserNumber()
            Constants.USERDEFAULTS.removeCurrentUserName()
            Constants.USERDEFAULTS.removeCurrentUserGender()
            Constants.USERDEFAULTS.removeCurrentUserCode()
            Constants.USERDEFAULTS.removeBatterySharing()
            Constants.USERDEFAULTS.removeLocationSharing()
            Constants.USERDEFAULTS.removeNotificationSharing()
            Constants.USERDEFAULTS.removeCameraSharing()
            Constants.USERDEFAULTS.removeMotionSharing()
            Constants.USERDEFAULTS.removeProfileImage()
            
            self.firebaseManager.deleteUserAccount(userPhoneNumber: self.lbl_number.text ?? "") { success in
                self.hideLoader()
                if success {
                    self.navigateToOnboarding()
                } else {
                    self.showAlert(title: "", message: "Some error please try sometimes")
                }
            }
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton) {
        showLoader(text: "Updating...")
        firebaseManager.updateUserNameInFirebase(userPhonenumber: lbl_number.text ?? "", entername: txt_name.text ?? "") { updated, errorMessage in
            self.hideLoader()
            self.txt_name.isUserInteractionEnabled = false
            if updated {
                Constants.USERDEFAULTS.saveCurrentuserName(value: self.txt_name.text ?? "")
                Constants.USERDEFAULTS.saveCurrentuserGender(value: self.btnMale.layer.borderWidth == 2 ? "Male" : "Female")
                
                let vc = StoryboardScene.Settings.popupProfileUpdateSuccess.instantiate()
                vc.closePopup = {
                    self.navigationController?.popViewController(animated: true)
                }
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false)
            } else {
                self.showAlert(title: "", message: errorMessage ?? "")
            }
        }
    }
}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // This method gets called when the user selects an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil) // Dismiss the picker
        var selectedImage = UIImage()
        if let editedImage = info[.editedImage] as? UIImage {
            print("Selected edited image: \(selectedImage)")
            selectedImage = editedImage
            profile_img.image = selectedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            print("Selected original image: \(originalImage)")
            selectedImage = originalImage
            profile_img.image = originalImage
        }
        Constants.USERDEFAULTS.saveProfileImage(value: profile_img.image?.pngData() ?? Data())
        
        firebaseManager.uploadProfileImage(selectedImage) { result in
            switch result {
            case .success(let url):
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
        picker.dismiss(animated: true, completion: nil)
        print("Image picker cancelled")
    }
}
