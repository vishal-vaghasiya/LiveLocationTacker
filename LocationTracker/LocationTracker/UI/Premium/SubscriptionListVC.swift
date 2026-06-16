//
//  SubscriptionListVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 08/08/25.
//

import UIKit

class SubscriptionListVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var activePlanStackView: UIStackView!
    @IBOutlet weak var activePlanCV: UICollectionView!
    @IBOutlet weak var manageButton: GradientButton!
    @IBOutlet weak var subscribeButton: GradientButton!
    
    // MARK: - PROPERTY
    var arrOfActivePlan : [PlanStatus] = []
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        setupButton()
        
        activePlanCV.register( UINib(nibName: ActivePlanCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: ActivePlanCVCell.identifier)
        activePlanCV.register( UINib(nibName: ChangePlanButtonCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: ChangePlanButtonCVCell.identifier)
        
        getActivePlans()
    }
    
    func setupButton() {
        manageButton.configure(title: "Manage Subscription", showArrow: false, isEnabled: true)
        manageButton.onTap = {
            FirebaseManager.shared.logAnalyticsEvent(name: .subscription_click_manageplan)
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        subscribeButton.configure(title: "Subscribe Plan", showArrow: false, isEnabled: true)
        subscribeButton.onTap = {
            FirebaseManager.shared.logAnalyticsEvent(name: .subscription_click_subscribeplan)
            let vc = StoryboardScene.Premium.premiumVC.instantiate()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backButtonClick(_ sender: UIButton) {
        self.navigateBack()
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    func getActivePlans(){
        Loader.show("Loading...")
        RevenueCatManager.shared.getCurrentPlanStatus { status in
            Loader.hide()
            self.noDataView.isHidden = true
            self.manageButton.isHidden = false
            if status.count == 0 {
                print("No active plan.")
                self.noDataView.isHidden = false
                self.manageButton.isHidden = true
                return
            }
            self.arrOfActivePlan = status
            self.arrOfActivePlan.append(PlanStatus(productId: "", planDuration: "", productPrice: "", expirationDate: nil, isTrial: false, daysRemaining: 0, billType: ""))
            self.activePlanCV.reloadData()
        }
    }
    
    // MARK: - DELEGATE

}
extension SubscriptionListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrOfActivePlan.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < self.arrOfActivePlan.count - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivePlanCVCell.identifier, for: indexPath) as! ActivePlanCVCell
            let data = self.arrOfActivePlan[indexPath.row]
            cell.data = data
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChangePlanButtonCVCell.identifier, for: indexPath) as! ChangePlanButtonCVCell
            cell.changePlanButton.addTarget(self, action: #selector(changePlanButtonTapped(_ :)), for: .touchUpInside)
            return cell
        }
    }
    
    @objc func changePlanButtonTapped(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .subscription_click_changeplan)
        let vc = StoryboardScene.Premium.premiumVC.instantiate()
        let nv = UINavigationController(rootViewController: vc)
        nv.navigationBar.isHidden = true
        nv.modalPresentationStyle = .overFullScreen
        self.present(nv, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: view.frame.width - 30, height: 202)
        }
        return CGSize(width: collectionView.frame.width, height: 55)
    }
    
}

