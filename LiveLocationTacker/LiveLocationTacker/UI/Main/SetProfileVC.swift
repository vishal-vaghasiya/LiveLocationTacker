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
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIView!
    
    let firebaseManager = FirebaseManager.shared
    var profileURL = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txt_name.text = DefaultManager.User.NAME
        txt_name.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        profile_img.setImage(urlString: DefaultManager.User.PROFILE_PIC, name: DefaultManager.User.NAME, placeholderImage: Asset.iconDefaultProfile.image, width: profile_img.frame.width * 2, height: profile_img.frame.height * 2)
        btnUpdate.isEnabled = txt_name.text?.count ?? 0 > 0
        self.setBannerAds()
    }
    
    func setBannerAds() {
        AdManager.shared.loadBannerAd(in: self.bannerView, rootViewController: self) { isShow in
            if isShow {
                UIView.animate(withDuration: 0.5) {
                    self.contBannerHeight.constant = 50
                    self.view.layoutIfNeeded()
                }
            } else {
                self.contBannerHeight.constant = 0
            }
        }
    }
    
    @IBAction func clickName(_ sender: UITextField) {
        FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_click_entername)
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnEditimgAction(_ sender: UIButton) {
        let vc = StoryboardScene.Main.photoPickerPopup.instantiate()
        vc.selectedSourceType = { (type) in
            FirebaseManager.shared.logAnalyticsEvent(name: type == .camera ? .createprofile_uploadphoto_click_takephoto : .createprofile_uploadphoto_click_choose_from_gallery)
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = type
            imagePickerController.allowsEditing = true
            DispatchQueue.main.async {
                self.present(imagePickerController, animated: true)
            }
        }
        vc.cancelClick = {
            FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_uploadphoto_click_cancel)
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @IBAction func btnUpdateProfileAction(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: sender.tag == 0 ? .createprofile_click_male : .createprofile_clik_female)
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
        FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_click_done)
        showLoader(text: "Updating...")
        //        firebaseManager.updateUserNameInFirebase(userPhonenumber: DefaultManager.User.PHONE,entername: txt_name.text ?? "") { updated, errorMessage in
        //            hideLoader()
        //            if updated {
        //                DefaultManager.IS_INITIAL_SETUP = true
        //                DefaultManager.User.NAME = self.txt_name.text ?? ""
        //                DefaultManager.User.GENDER = self.btnMale.layer.borderWidth == 2 ? "Male" : "Female"
        //                self.navigateToHome()
        //            }
        //            else{
        //                self.showAlert(title: "", message: errorMessage ?? "")
        //            }
        //        }
        
        var updatedData: [String: Any] = [
            FirebaseKeys.name: txt_name.text ?? "",
            FirebaseKeys.gender: self.btnMale.layer.borderWidth == 2 ? "Male" : "Female",
        ]
        
        if !profileURL.isEmpty {
            updatedData[FirebaseKeys.profilePicture] = profileURL
        }

        firebaseManager.updateUserData(updatedValues: updatedData) { success, message in
            print(message)
            hideLoader()
            if success {
                DefaultManager.IS_INITIAL_SETUP = true
                DefaultManager.User.NAME = self.txt_name.text ?? ""
                DefaultManager.User.GENDER = self.btnMale.layer.borderWidth == 2 ? "Male" : "Female"
                if !self.profileURL.isEmpty {
                    DefaultManager.User.PROFILE_PIC = self.profileURL
                }
                isComeFromLogin = true
                self.navigateToHome()
            } else {
                showToastMessage(message)
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
            selectedImage = editedImage
            profile_img.image = selectedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            profile_img.image = originalImage
        }
        DefaultManager.User.PROFILE_DATA = profile_img.image?.pngData() ?? Data()
        
        showLoader(text: "Uploading profile...")
        firebaseManager.uploadProfileImage(selectedImage) { result in
            hideLoader()
            switch result {
            case .success(let url):
                print(url)
                self.profileURL = url.absoluteString
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
