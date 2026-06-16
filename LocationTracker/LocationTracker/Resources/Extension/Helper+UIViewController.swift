//
//  Helper.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit
import FlagPhoneNumber

extension UIViewController {
    /// Navigates back to the root of the navigation stack
    func navigateToRootViewController() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    /// Navigates back to the previous view controller
    func navigateBack(animated: Bool = true) {
        self.navigationController?.popViewController(animated: animated)
    }
    
    /// Presents a simple alert with an OK button
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }
    
    /// For select country code for phone number.
    func presentCountryCodePicker(completion: @escaping (String, UIImage) -> ()) {
        let list = FPNCountryListViewController(style: .grouped)
        let repo = FPNCountryRepository()               // repository without using FPNTextField
        list.setup(repository: repo)
        
        // Optional filters:
        // list.displayOnlyCountries = [.IN, .US, .AE]
        // list.excludedCountries = [.AQ]
        
        list.didSelect = { [weak self] country in
            let dial = country.phoneCode                 // "+91"
            let flag = country.flag ?? UIImage()                
            let digitsOnly = dial.filter("0123456789".contains) // "91"
            // Use whichever you need:
            completion(dial, flag)          // or digitsOnly
            self?.dismiss(animated: true)
        }
        
        let nav = UINavigationController(rootViewController: list)
        present(nav, animated: true)
    }
    
}
