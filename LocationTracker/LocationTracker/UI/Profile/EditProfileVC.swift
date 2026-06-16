//
//  EditProfileVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//

import UIKit

class EditProfileVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var txtFirstName: OutlinedFloatingTextField!
    @IBOutlet weak var txtLastName: OutlinedFloatingTextField!
    
    @IBOutlet weak var maleView: UIView!
    @IBOutlet weak var ivMale: UIImageView!
    @IBOutlet weak var lblMale: UILabel!
    
    @IBOutlet weak var feMaleView: UIView!
    @IBOutlet weak var ivFemale: UIImageView!
    @IBOutlet weak var lblFemale: UILabel!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var updateButton: PrimaryButton!
    // MARK: - PROPERTY
    var profileURL = String()
    var selectedGender: GenderType?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        ivProfile.setImage(urlString: DefaultManager.User.PROFILE_PIC, name: DefaultManager.User.NAME, placeholderImage: Asset.iconDefaultProfile.image)
        txtFirstName.text = DefaultManager.User.FIRST_NAME
        txtLastName.text = DefaultManager.User.LAST_NAME
        
        txtFirstName.addTarget(self, action: #selector(nameDidChange(_:)), for: .editingChanged)
        txtLastName.addTarget(self, action: #selector(nameDidChange(_:)), for: .editingChanged)
        
        selectedGender = DefaultManager.User.GENDER == "Male" ? .Male : .Female
        profileURL = DefaultManager.User.PROFILE_PIC
        btnRemove.isHidden = DefaultManager.User.PROFILE_PIC.isEmpty
        
        updateButton.isEnabled = false
        setupGenderData()
        setNativeAd()
    }
    
    func setupButton() {
        let isEnable = !txtFirstName.text!.isEmpty && !txtLastName.text!.isEmpty && (selectedGender != nil)
        self.updateButton.isEnabled = isEnable
    }
    
    func setupGenderData(){
        self.maleView.borderColor = selectedGender == .Male ? Asset.appMain.color : Asset.appLightGrey.color
        self.feMaleView.borderColor = selectedGender == .Female ? Asset.appMain.color : Asset.appLightGrey.color
        self.ivMale.isHighlighted = selectedGender == .Male
        self.ivFemale.isHighlighted = selectedGender == .Female
        self.lblMale.isEnabled = selectedGender == .Male
        self.lblFemale.isEnabled = selectedGender == .Female
    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backButtonClick(_ sender: UIButton) {
        self.navigateToRootViewController()
    }
    
    @IBAction func removeProfileButtonClick(_ sender: UIButton) {
        Loader.show("Removing...")
        FirebaseManager.shared.deleteUserProfileImage(filePath: profileURL) { success, message in
            Loader.hide()
            if success {
                showToast(message: message)
                self.profileURL = ""
                self.btnRemove.isHidden = true
                self.ivProfile.image = Asset.iconDefaultProfile.image
                DefaultManager.User.PROFILE_PIC = ""
            } else {
                showToast(message: message)
            }
        }
    }
    
    @IBAction func changeProfileButtonClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .profile_click_uploadphoto)
        
        let actionSheet = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        
        // Take Photo
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            FirebaseManager.shared.logAnalyticsEvent(name: .profile_uploadphoto_click_takephoto)
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }))
        
        // Choose From Gallery
        actionSheet.addAction(UIAlertAction(title: "Choose From Gallery", style: .default, handler: { _ in
            FirebaseManager.shared.logAnalyticsEvent(name: .profile_uploadphoto_click_choose_from_gallery)
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }))
        
        // Cancel
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            FirebaseManager.shared.logAnalyticsEvent(name: .profile_uploadphoto_click_cancel)
        }))
        
        // For iPad support (ActionSheet crashes without this)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func selectMaleClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .profile_click_male)
        self.selectedGender = .Male
        self.setupGenderData()
        setupButton()
    }
    
    @IBAction func selectFemaleClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .profile_clik_female)
        self.selectedGender = .Female
        self.setupGenderData()
        setupButton()
    }
    
    @IBAction func updateButtonClick(_ sender: PrimaryButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .profile_click_update)
        Loader.show("Updating...")
        var updatedData: [String: Any] = [
            FirebaseKeys.fName: self.txtFirstName.text ?? "",
            FirebaseKeys.lName: self.txtLastName.text ?? "",
            FirebaseKeys.name: getFullName(firstName: self.txtFirstName.text, lastName: self.txtLastName.text),
            FirebaseKeys.gender: self.selectedGender == .Male ? "Male" : "Female",
        ]
        
        if !self.profileURL.isEmpty {
            updatedData[FirebaseKeys.profilePicture] = self.profileURL
        }
        
        FirebaseManager.shared.updateUserData(updatedValues: updatedData) { success, message in
            Loader.hide()
            if success {
                DefaultManager.IS_INITIAL_SETUP = true
                DefaultManager.User.FIRST_NAME = self.txtFirstName.text ?? ""
                DefaultManager.User.LAST_NAME = self.txtLastName.text ?? ""
                DefaultManager.User.GENDER = self.selectedGender == .Male ? "Male" : "Female"
                if !self.profileURL.isEmpty {
                    DefaultManager.User.PROFILE_PIC = self.profileURL
                }
                isComeFromLogin = true
                goToDashboard()
            } else {
                showToast(message: message)
            }
        }
    }
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    @objc func nameDidChange(_ textField: UITextField) {
        setupButton()
    }
    
}
extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage = UIImage()
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        picker.dismiss(animated: true, completion: {
            let vc = StoryboardScene.Profile.setProfilePicVC.instantiate()
            vc.selectedImage = selectedImage
            vc.didFinishCropping = { image in
                self.ivProfile.image = image
                Loader.show("Uploading profile...")
                FirebaseManager.shared.uploadProfileImage(image) { result in
                    Loader.hide()
                    switch result {
                    case .success(let url):
                        FirebaseManager.shared.updateUserProfilePicture(for: url.absoluteString) { success, message in
                            showToast(message: message)
                            if success {
                                self.profileURL = url.absoluteString
                                self.btnRemove.isHidden = false
                                DefaultManager.User.PROFILE_PIC = self.profileURL
                            }
                        }
                        break
                    case .failure(let error):
                        print("Upload failed: \(error)")
                    }
                }
            }
            self.present(vc, animated: false)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
