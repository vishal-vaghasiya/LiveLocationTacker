//
//  SetupProfileVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 06/08/25.
//

import UIKit

class SetupProfileVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var txtFirstName: OutlinedFloatingTextField!
    @IBOutlet weak var txtLastName: OutlinedFloatingTextField!
    @IBOutlet weak var btnUploadPhotos: UIButton!
    
    @IBOutlet weak var maleView: UIView!
    @IBOutlet weak var ivMale: UIImageView!
    @IBOutlet weak var lblMale: UILabel!
    
    @IBOutlet weak var lblGenderTitle: UILabel!
    @IBOutlet weak var feMaleView: UIView!
    @IBOutlet weak var ivFemale: UIImageView!
    @IBOutlet weak var lblFemale: UILabel!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    @IBOutlet weak var continueButton: PrimaryButton!
    
    // MARK: - PROPERTY
    var profileURL = String()
    var selectedGender: GenderType?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        txtFirstName.addTarget(self, action: #selector(nameDidChange(_:)), for: .editingChanged)
        txtLastName.addTarget(self, action: #selector(nameDidChange(_:)), for: .editingChanged)
        
        txtFirstName.text = DefaultManager.User.FIRST_NAME
        txtLastName.text = DefaultManager.User.LAST_NAME
        ivProfile.setImage(urlString: DefaultManager.User.PROFILE_PIC, name: DefaultManager.User.NAME, placeholderImage: Asset.iconSelectProfile.image)
        profileURL = DefaultManager.User.PROFILE_PIC
        
        if !DefaultManager.User.GENDER.isEmpty {
            self.selectedGender = DefaultManager.User.GENDER == "Male" ? .Male : .Female
        }
        
        setupButton()
        setNativeAd()
        setupGenderData()
    }
    
    func setupLocalization() {
        self.lblTitle.text = L10n.setProfile
        self.lblSubTitle.text = L10n.completeYourProfileDetails
        self.txtFirstName.placeholder = L10n.enterFirstName
        self.txtLastName.placeholder = L10n.enterLastName
        self.lblGenderTitle.text = L10n.selectGender
        self.lblMale.text = L10n.male
        self.lblFemale.text = L10n.female
        self.btnUploadPhotos.setTitle(L10n.uploadPhoto, for: .normal)
        self.continueButton.setTitle(L10n.continue, for: .normal)
    }
    
    func setupGenderData(){
        self.maleView.borderColor = selectedGender == .Male ? Asset.appMain.color : Asset.appLightGrey.color
        self.feMaleView.borderColor = selectedGender == .Female ? Asset.appMain.color : Asset.appLightGrey.color
        self.ivMale.isHighlighted = selectedGender == .Male
        self.ivFemale.isHighlighted = selectedGender == .Female
        self.lblMale.isEnabled = selectedGender == .Male
        self.lblFemale.isEnabled = selectedGender == .Female
    }
    
    func setupButton() {
        let isEnable = !txtFirstName.text!.isEmpty && !txtLastName.text!.isEmpty && (selectedGender != nil) && !profileURL.isEmpty
        self.continueButton.isEnabled = isEnable
    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func continueButtonClick(_ sender: PrimaryButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_click_done)
        Loader.show("Updating...")
        var updatedData: [String: Any] = [
            FirebaseKeys.name: getFullName(firstName: txtFirstName.text, lastName: txtLastName.text),
            FirebaseKeys.fName: txtFirstName.text ?? "",
            FirebaseKeys.lName: txtLastName.text ?? "",
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
                DefaultManager.Permission.PROXIMITY_NOTIFICATION = true
                goToDashboard()
            } else {
                showToast(message: message)
            }
        }
    }
    
    @IBAction func selectProfileButtonClick(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        
        // Take Photo
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_uploadphoto_click_takephoto)
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }))
        
        // Choose From Gallery
        actionSheet.addAction(UIAlertAction(title: "Choose From Gallery", style: .default, handler: { _ in
            FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_uploadphoto_click_choose_from_gallery)
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }))
        
        // Cancel
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_uploadphoto_click_cancel)
        }))
        
        // For iPad support (ActionSheet crashes without this)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(actionSheet, animated: true, completion: nil)
        
        /*let vc = StoryboardScene.Profile.popupChooseOptions.instantiate()
        vc.selectedSourceType = { type in
            FirebaseManager.shared.logAnalyticsEvent(name: type == .camera ? .createprofile_uploadphoto_click_takephoto : .createprofile_uploadphoto_click_choose_from_gallery)
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = type
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }
        vc.onCancelTapped = {
            //Cancel Click
            FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_uploadphoto_click_cancel)
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)*/
    }
    
    @IBAction func selectMaleClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_click_male)
        self.selectedGender = .Male
        self.setupGenderData()
        setupButton()
    }
    
    @IBAction func selectFemaleClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .createprofile_clik_female)
        self.selectedGender = .Female
        self.setupGenderData()
        setupButton()
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    @objc func nameDidChange(_ textField: UITextField) {
        setupButton()
    }
    
}
extension SetupProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                        self.profileURL = url.absoluteString
                        self.setupButton()
                        break
                    case .failure(let error):
                        print("Upload failed: \(error)")
                    }
                }
            }
            self.present(vc, animated: false)
        })
        
        /*Loader.show("Uploading profile...")
        FirebaseManager.shared.uploadProfileImage(selectedImage) { result in
            Loader.hide()
            switch result {
            case .success(let url):
                self.profileURL = url.absoluteString
                self.setupButton()
                break
            case .failure(let error):
                print("Upload failed: \(error)")
            }
        }*/
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
