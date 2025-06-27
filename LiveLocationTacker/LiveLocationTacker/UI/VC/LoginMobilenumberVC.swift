//
//  LoginMobilenumberVC.swift
//  LiveLocationTacker
//
//  Created by DREAMWORLD on 16/11/24.
//

import UIKit
import SKCountryPicker
import PhoneNumberKit
import ContactsUI
import FirebaseAuth



class LoginMobilenumberVC: UIViewController {

    @IBOutlet var shadow_view: [UIView]!
    @IBOutlet weak var img_flag: UIImageView!
    @IBOutlet weak var invalid_view: UIView!
    @IBOutlet weak var lbl_countrycode: UILabel!
    @IBOutlet weak var txtEnterNumber: UITextField!
    @IBOutlet weak var btnContinue: UIEnableDisable!
    let phoneNumberKit = PhoneNumberKit()
    let groupManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        
        lbl_countrycode.text = CountryManager.shared.currentCountry?.dialingCode
        img_flag.image = CountryManager.shared.currentCountry?.flag
        invalid_view.isHidden =  true
        txtEnterNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        //sendOTP(phoneNumber: "+919725992972")
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnContineAction(_ sender: UIButton) {
        let number = "\(CountryManager.shared.currentCountry?.dialingCode ?? "")\(txtEnterNumber.text ?? "")"
        sendOTP(phoneNumber: number)
    }
    
    func sendOTP(phoneNumber: String) {
//        showLoader(text: "Loading...")
//        groupManager.sendMobileOTP(phoneNumber: phoneNumber.removingSpaces) { success, error in
//            self.hideLoader()
//            self.showToastMessage(error ?? "")
//            if success {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MobileOTPVerificationVC") as! MobileOTPVerificationVC
                vc.mobileNumber = phoneNumber
                vc.displayMobileNumber = "\(CountryManager.shared.currentCountry?.dialingCode ?? "") \(self.txtEnterNumber.text ?? "")"
                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
    }
    
//    func creatingStaticCircle(){
//        showLoader(text: "Loading...")
//        
//        UIDevice.current.isBatteryMonitoringEnabled = true
//        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
//        
//        //groupManager.deleteUserAccount(userPhoneNumber: txtEnterNumber.text ?? "") { [self] isDeleted in
//        groupManager.createCircle(name: "My Circles",
//                                  userName: txt_entername.text ?? "",
//                                  userPhone: txtEnterNumber.text ?? "",
//                                  batteryLevel: batteryLevel) { [self] generatedCode in
//            print("Share this code with your friend: \(generatedCode ?? "")")
//            
//            Constants.USERDEFAULTS.saveCurrentuserNumber(value: txtEnterNumber.text ?? "")
//            Constants.USERDEFAULTS.saveCurrentuserName(value: txt_entername.text ?? "")
//            Constants.USERDEFAULTS.saveCurrentuserCode(value: generatedCode ?? "")
//            Constants.USERDEFAULTS.saveBatterySharing(value: true)
//            Constants.USERDEFAULTS.saveLocationSharing(value: true)
//            Constants.USERDEFAULTS.saveNotificationSharing(value: true)
//            Constants.USERDEFAULTS.saveProfileImage(value: UIImage(named: "engineer")?.pngData() ?? Data())
//            
//            self.hideLoader()
//            
//            self.pushVC(T: SetProfileVC.instantiate(appStoryboard: .main), viewControllerID: String(describing: SetProfileVC.self))
//        }
//        //}
//    }
    
    
    @IBAction func btnChooseFromContactAction(_ sender: UIButton) {
        showContactPicker()
    }
    
    @IBAction func btnCountryPickerAction(_ sender: UIButton) {
        CountryPickerWithSectionViewController.presentController(on: self) { country in
            self.img_flag.image = country.flag
            self.lbl_countrycode.text = country.dialingCode
        }
    }
    
    @IBAction func txtNumberEdtingChanged(_ sender: UITextField) {
//        let fullPhoneNumber = (lbl_countrycode.text ?? "") + (txtEnterNumber.text ?? "")
//        if phoneNumberKit.isValidPhoneNumber(fullPhoneNumber) {
//            invalid_view.isHidden = true
//        }
//        else{
//            invalid_view.isHidden = false
//        }
    }
    
    func showContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        DispatchQueue.main.async {
            self.present(contactPicker, animated: true, completion: nil)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        setupButton()
    }
    
    func setupButton() {
        let countryCode = lbl_countrycode.text ?? ""
        self.btnContinue.isEnabled = (!(countryCode.isEmpty) && (txtEnterNumber.text?.count ?? 0 >= 11))
    }
}


extension LoginMobilenumberVC: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // Extract the contact's full name
        //let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
        
        // Initialize PhoneNumberKit
        let phoneNumberKit = PhoneNumberKit()
        
        // Extract the first phone number if available
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            do {
                // Parse the phone number to get the country dialing code
                let parsedPhoneNumber = try phoneNumberKit.parse(phoneNumber)
                let dialingCode = "+\(parsedPhoneNumber.countryCode)"
                let nationalNumber = parsedPhoneNumber.nationalNumber
            
                // Assign values to your UI components
                self.lbl_countrycode.text = dialingCode
                self.txtEnterNumber.text = "\(nationalNumber)"
                self.img_flag.image = CountryManager.shared.country(withDigitCode: dialingCode)?.flag
                self.setupButton()
            } catch {
                print("Error parsing phone number: \(error.localizedDescription)")
            }
        } 
        else {
            // Handle case where no phone number is available
            self.lbl_countrycode.text = "No Country Code"
            self.txtEnterNumber.text = "No Phone Number"
            img_flag.image = nil
            self.setupButton()
        }
    }
}
