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
    let groupManager = FirebaseManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        round_imgview.makeRounded()
        pencil_view.makeRounded()
        
        //btnUpdate.setButtonTitleAndFunctionality("Done")
        //txt_name.text = Constants.USERDEFAULTS.getCurrentuserName()
        //profile_img.image = UIImage(data: Constants.USERDEFAULTS.getProfileImage() ?? Data())
        txt_name.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnEditimgAction(_ sender: UIButton) {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.sourceType = .photoLibrary // Allow selecting images from the photo library
//        imagePickerController.allowsEditing = true
//        DispatchQueue.main.async {
//            self.present(imagePickerController, animated: true)
//        }
        
//        let vc = IS_IPHONE ? StoryboardScene.ManageTeam.selectAssignTagVC.instantiate() : StoryboardScene.ManageTeamIPad.selectAssignTagVC.instantiate()
//        //let vc = IS_IPHONE ? StoryboardScene.ManageTeam.selectTeamTagVC.instantiate() : StoryboardScene.ManageTeamIPad.selectTeamTagVC.instantiate()
//        vc.callManageTeamApi = { (dict) in
//            self.getBranchTeamUsers()
//        }
//        vc.modalPresentationStyle = .overCurrentContext
//        self.present(vc, animated: false)
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
        //        showLoader(text: "Updating...")
        //
        //        groupManager.updateUserNameInFirebase(userPhonenumber: Constants.USERDEFAULTS.getCurrentuserNumber(),entername: txt_name.text ?? "") { updated, errorMessage in
        //            self.hideLoader()
        //
        //            if updated {
        //                Constants.USERDEFAULTS.set(true, forKey: "isIntro")
        //                Constants.USERDEFAULTS.saveCurrentuserName(value: self.txt_name.text ?? "")
        //                Constants.USERDEFAULTS.saveCurrentuserGender(value: self.btnMale.layer.borderWidth == 2 ? "Male" : "Female")
        //
        self.navigateToHome()
        //            }
        //            else{
        //                self.showAlert(title: "", message: errorMessage ?? "")
        //            }
        //        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        btnUpdate.isEnabled = textField.text?.count ?? 0 > 0
    }
}


extension SetProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
