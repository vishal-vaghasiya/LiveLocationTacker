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
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var round_imgview: UIView!
    @IBOutlet weak var pencil_view: UIView!
    @IBOutlet weak var lbl_number: UILabel!
    @IBOutlet weak var txt_name: UITextField!
    let groupManager = FirebaseManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        round_imgview.makeRounded()
        pencil_view.makeRounded()
        
        btnUpdate.setButtonTitleAndFunctionality("Update")
        txt_name.text = Constants.USERDEFAULTS.getCurrentuserName()
        lbl_number.text = Constants.USERDEFAULTS.getCurrentuserNumber()
        profile_img.image = UIImage(data: Constants.USERDEFAULTS.getProfileImage() ?? Data())
        
        if Constants.USERDEFAULTS.getCurrentuserGender() == "Male" {
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
    
    @IBAction func btnEditimgAction(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary // Allow selecting images from the photo library
        imagePickerController.allowsEditing = true
        DispatchQueue.main.async {
            self.present(imagePickerController, animated: true)
        }
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
        showDeleteAccountAlert()
    }
    
    func showDeleteAccountAlert() {
        // Show confirmation alert
        let alertController = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )

        // Add "Delete" action
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
            showLoader(text: "Deleting...")
            
            Constants.USERDEFAULTS.removeObject(forKey: "isIntro")
            Constants.USERDEFAULTS.removeCurrentUserNumber()
            Constants.USERDEFAULTS.removeCurrentUserName()
            Constants.USERDEFAULTS.removeCurrentUserGender()
            Constants.USERDEFAULTS.removeCurrentUserCode()
            Constants.USERDEFAULTS.removeBatterySharing()
            Constants.USERDEFAULTS.removeLocationSharing()
            Constants.USERDEFAULTS.removeNotificationSharing()
            Constants.USERDEFAULTS.removeProfileImage()

            groupManager.deleteUserAccount(userPhoneNumber: lbl_number.text ?? "") { deleted in
                self.hideLoader()
                
                if deleted {
                    self.navigateToOnboarding()
                }
                else{
                    self.showAlert(title: "", message: "Some error please try sometimes")
                }
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton) {
        showLoader(text: "Updating...")
        
        groupManager.updateUserNameInFirebase(userPhonenumber: lbl_number.text ?? "", entername: txt_name.text ?? "") { updated, errorMessage in
            self.hideLoader()
            
            if updated {
                Constants.USERDEFAULTS.saveCurrentuserName(value: self.txt_name.text ?? "")
                Constants.USERDEFAULTS.saveCurrentuserGender(value: self.btnMale.layer.borderWidth == 2 ? "Male" : "Female")
                self.navigationController?.popViewController(animated: true)
            }
            else{
                self.showAlert(title: "", message: errorMessage ?? "")
            }
        }
    }
}


extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // This method gets called when the user selects an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil) // Dismiss the picker
        
        if let selectedImage = info[.editedImage] as? UIImage {
            print("Selected edited image: \(selectedImage)")
            profile_img.image = selectedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            print("Selected original image: \(originalImage)")
            profile_img.image = originalImage
        }
        Constants.USERDEFAULTS.saveProfileImage(value: profile_img.image?.pngData() ?? Data())
    }
    
    // This method gets called when the user cancels the picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("Image picker cancelled")
    }
}
