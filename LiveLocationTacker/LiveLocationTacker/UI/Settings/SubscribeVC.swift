//
//  SubscribeVC.swift
//
//  Created by DREAMWORLD on 19/09/24.
//

import UIKit
import RevenueCat
import ProgressHUD
import AppTrackingTransparency

class SubscribeVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var lbl_3daytrail: UILabel!
    @IBOutlet weak var lbl_year_price: UILabel!
    @IBOutlet weak var lbl_month_price: UILabel!
    @IBOutlet weak var lbl_week_price: UILabel!
    @IBOutlet weak var btnSubscibeNow: UIEnableDisable!
    
    @IBOutlet weak var img_bg_year: UIImageView!
    @IBOutlet weak var img_bg_month: UIImageView!
    @IBOutlet weak var img_bg_week: UIImageView!
    
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var btnTermofuse: UIButton!
    @IBOutlet weak var btnPrivacy: UIButton!
    @IBOutlet weak var btnRestore: UIButton!
    
    var offering: Offering?
    var isFromTrailProScreen: Bool = false
    var takingPremuium: () -> () = { }
    var isFromSplash = false
    var onTapDismissControllerAction: () -> () = { }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reachability.connection == .unavailable || interNetConnectionAvailable == false {
            self.showAlertForNoInternetConnection()
        }
        
        initView()
        btnSubscibeNow.isEnabled = true
        getOfferFromRevenuecut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.btnClose.isHidden = false
        }
    }
    
    func initView() {
        img_bg_year.isHighlighted = true
        
        yearView.backgroundColor = .maincolor
        lbl_year_price.textColor = .white
        
        weekView.backgroundColor = .cellBg
        lbl_week_price.textColor = .fontGraycolor
        
        monthView.backgroundColor = .cellBg
        lbl_month_price.textColor = .fontGraycolor
    }
    
    func getOfferFromRevenuecut() {
        Purchases.shared.getOfferings { [self] (offerings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            offering = offerings?.current
            btnSubscibeNow.isEnabled = true
            
            if let packages = self.offering?.availablePackages {
                for (_, package) in packages.enumerated() {
                    if package.packageType == .annual {
                        self.lbl_year_price.text = "\(package.localizedPriceString) / \("Yearly")"
                        self.lbl_3daytrail.text = "\(package.localizedPriceString) / \("bottom_trail")"
                    } else if package.packageType == .monthly {
                        self.lbl_month_price.text = "\(package.localizedPriceString) / \("Monthly")"
                    } else if package.packageType == .weekly {
                        self.lbl_week_price.text = "\(package.localizedPriceString) / \("Weekly")"
                    }
                }
            }
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnCloseAction(_ sender: UIButton) {
        if isFromSplash {
            DefaultManager.IS_INITIAL_SETUP = true
            self.navigateToHome()
        } else {
            dismiss(animated: true) {
                self.onTapDismissControllerAction()
            }
        }
    }
    
    @IBAction func btnRestoreAction(_ sender: UIButton) {
        ProgressHUD.animate(interaction: false)
        Purchases.shared.restorePurchases { (purchaserInfo, error) in
            ProgressHUD.dismiss()
            if let error = error {
                self.present(self.errorAlert(message: error.localizedDescription), animated: true, completion: nil)
            }
            self.refreshUserDetails()
        }
    }
    
    @IBAction func btnPackageSelectionAction(_ sender: UIButton) {
        let weekSelected = sender.tag == 0
        let monthSelected = sender.tag == 1
        let yearSelected = sender.tag == 2
        
        img_bg_week.isHighlighted = weekSelected
        img_bg_month.isHighlighted = monthSelected
        img_bg_year.isHighlighted = yearSelected
        
        switch sender.tag {
        case 0:
            weekView.backgroundColor = .maincolor
            lbl_week_price.textColor = .white
            
            monthView.backgroundColor = .cellBg
            lbl_month_price.textColor = .fontGraycolor
            
            yearView.backgroundColor = .cellBg
            lbl_year_price.textColor = .fontGraycolor
            
            self.lbl_3daytrail.text = "\(offering?.weekly?.localizedPriceString ?? "") / Weekly , Automatic Renewal and Cancel anytime."
        case 1:
            monthView.backgroundColor = .maincolor
            lbl_month_price.textColor = .white
            
            weekView.backgroundColor = .cellBg
            lbl_week_price.textColor = .fontGraycolor
            
            yearView.backgroundColor = .cellBg
            lbl_year_price.textColor = .fontGraycolor
            
            self.lbl_3daytrail.text = "\(offering?.monthly?.localizedPriceString ?? "") / Monthly , Automatic Renewal and Cancel anytime."
        case 2:
            yearView.backgroundColor = .maincolor
            lbl_year_price.textColor = .white
            
            weekView.backgroundColor = .cellBg
            lbl_week_price.textColor = .fontGraycolor
            
            monthView.backgroundColor = .cellBg
            lbl_month_price.textColor = .fontGraycolor
            
            self.lbl_3daytrail.text = "\(offering?.annual?.localizedPriceString ?? "") / Yearly , Automatic Renewal and Cancel anytime."
        default:
            break
        }
    }
    
    @IBAction func btnSubscribeAction(_ sender: UIButton) {
        guard let packages = self.offering?.availablePackages else { return }
        
        for i in 0..<packages.count {
            let package = packages[i]
            
            if img_bg_week.isHighlighted, package.packageType == .weekly {
                buyProduct(index: i)
                break
            } else if img_bg_month.isHighlighted, package.packageType == .monthly {
                buyProduct(index: i)
                break
            } else if img_bg_year.isHighlighted, package.packageType == .annual {
                buyProduct(index: i)
                break
            }
        }
    }
    
    @IBAction func btnPrivacyPolicyAction(_ sender: UIButton) {
        guard let url = URL(string: PRIVACY) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnTermofUseAction(_ sender: UIButton) {
        guard let url = URL(string: TERMS) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - RevenueCat Purchase Methods

extension SubscribeVC {
    
    func buyProduct(index: Int) {
        showLoader(text: "loading")
        
        if let package = offering?.availablePackages[index] {
            Purchases.shared.purchase(package: package) { (transaction, purchaserInfo, error, userCancelled) in
                ProgressHUD.dismiss()
                if let error = error {
                    // Handle error if needed
                } else {
                    self.dismissModal()
                }
            }
        }
    }
    
    func dismissModal() {
        DefaultManager.IS_SUBSCRIPTION = true
        
        let alertController = UIAlertController(title: "Subscription Confirmed", message: "Your subscription has been successfully activated.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if self.isFromTrailProScreen {
                self.dismiss(animated: true) {
                    self.takingPremuium()
                }
            } else {
                self.navigateToHome()
            }
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func refreshUserDetails() {
        Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements["entitlementID"]?.isActive == true {
                DefaultManager.IS_SUBSCRIPTION = true
                
                let alertController = UIAlertController(title: "Restore Complete", message: "Your subscription has been successfully restored.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    if self.isFromTrailProScreen {
                        self.dismiss(animated: true) {
                            self.takingPremuium()
                        }
                    } else {
                        self.navigateToHome()
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.showAlert(title: "No Subscription Available", message: "Please subscribe first.")
                DefaultManager.IS_SUBSCRIPTION = false
            }
        }
    }
    
    func errorAlert(message: String) -> UIAlertController {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return errorAlert
    }
}
