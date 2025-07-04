//
//  SetProfileVC.swift
//  LiveLocationTacker
//
//  Created by Jay Gurudev on 14/02/25.
//

import UIKit

class SetProfileVC: UIViewController {
    
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var profile_img: UIImageView!
    @IBOutlet weak var btnUpdate: UIEnableDisable!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var round_imgview: UIView!
    @IBOutlet weak var pencil_view: UIView!
    @IBOutlet weak var txt_name: UITextField!
    let firebaseManager = FirebaseManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        round_imgview.makeRounded()
        pencil_view.makeRounded()
        
        //btnUpdate.setButtonTitleAndFunctionality("Done")
        txt_name.text = DefaultManager.User.NAME
        //profile_img.image = UIImage(data: Constants.USERDEFAULTS.getProfileImage() ?? Data())
        txt_name.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
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
    
    @IBAction func btnUpdateAction(_ sender: UIButton) {
        showLoader(text: "Updating...")
        firebaseManager.updateUserNameInFirebase(userPhonenumber: DefaultManager.User.PHONE,entername: txt_name.text ?? "") { updated, errorMessage in
            self.hideLoader()
            if updated {
                Constants.USERDEFAULTS.set(true, forKey: "isIntro")
                DefaultManager.User.NAME = self.txt_name.text ?? ""
                DefaultManager.User.GENDER = self.btnMale.layer.borderWidth == 2 ? "Male" : "Female"
                self.navigateToHome()
            }
            else{
                self.showAlert(title: "", message: errorMessage ?? "")
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        btnUpdate.isEnabled = textField.text?.count ?? 0 > 0
    }
}


extension SetProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
