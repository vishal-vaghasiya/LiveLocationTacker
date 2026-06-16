//
//  AddMemberVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit
import AEOTPTextField
import SKCountryPicker
import ContactsUI

class AddMemberVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnAdd: PrimaryButton!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var lblSelectContact: UILabel!
    @IBOutlet weak var lblLnvitationTitle: UILabel!
    @IBOutlet weak var lblInviteCode: UILabel!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    var invitationCode = String()
    var isAddToGroup: Bool = false
    var selectedCountyCode: String = "91"
    var onAddMemberCompletion: ((_ phoneNumber: String, _ countryCode: String) -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        self.setupDefault()
        self.setupContinueButton()
        self.setNativeAd()
    }
    
    func setupDefault(){
        lblCountryCode.text = CountryManager.shared.currentCountry?.dialingCode
        countryImage.image = CountryManager.shared.currentCountry?.flag
        
        txtPhoneNumber.addTarget(self, action: #selector(phoneNumberDidChange(_:)), for: .editingChanged)
        txtPhoneNumber.delegate = self
        
        lblInviteCode.text = invitationCode
    }
    
    func setupContinueButton() {
        let length = (txtPhoneNumber.text ?? "").count
        btnAdd.isEnabled = length >= 11
        fieldView.borderColor = length == 0 ? Asset.appLightGrey.color : Asset.appMain.color
    }
    
    func setupLocalization() {
        self.lblTitle.text = LocalizationKey.Add_Member.text
        self.lblDescription.text = LocalizationKey.Add_member_Description.text
        self.txtPhoneNumber.placeholder = LocalizationKey.Enter_your_phone_number.text
        self.lblSelectContact.text = LocalizationKey.Choose_From_Contact.text
        self.lblLnvitationTitle.text = LocalizationKey.Invitation_Code.text
        self.btnAdd.setTitle(LocalizationKey.Add.text, for: .normal)
    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigateBack()
    }
    
    @IBAction func clickCopyInviteCode(_ sender: UIButton) {
        copyToClipboard(text: self.invitationCode)
    }
    
    @IBAction func clickAdd(_ sender: PrimaryButton) {
        let code = selectedCountyCode
        let phone = (self.txtPhoneNumber.text ?? "").removingSpaces
        if isAddToGroup {
            Loader.show("Loading...")
            FirebaseManager.shared.addMemberToCircle(inviteCode: self.invitationCode, countryCode: code, phoneNumber: phone) { success, error in
                Loader.hide()
                if success {
                    self.navigateBack()
                } else {
                    showToast(message: error)
                }
            }
        } else {
            onAddMemberCompletion?(phone, code)
            self.navigateBack()
        }
    }
    
    @IBAction func ClickaddNumber(_ sender: UITextField) {
        FirebaseManager.shared.logAnalyticsEvent(name: .enter_click_addnumber)
    }
    
    @IBAction func clickSelectContact(_ sender: UIButton) {
        self.openContacts()
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    @objc func phoneNumberDidChange(_ textField: UITextField) {
        setupContinueButton()
    }
}

extension AddMemberVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        fieldView.borderColor = Asset.appMain.color
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setupContinueButton()
    }
}

extension AddMemberVC: CNContactPickerDelegate {

    func openContacts() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        // Optional: Limit the fields you want to display
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        self.present(contactPicker, animated: true, completion: nil)
    }

    // MARK: - CNContactPickerDelegate methods
    
    // Called when user selects a single contact
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let name = "\(contact.givenName) \(contact.familyName)"
        
        // Example: Get first phone number
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            print("Name: \(name), Phone: \(phoneNumber)")
            self.txtPhoneNumber.text = phoneNumber
        } else {
            print("Name: \(name), No phone number found")
        }
    }

    // Called when user cancels
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("User canceled contact picker")
    }
}
