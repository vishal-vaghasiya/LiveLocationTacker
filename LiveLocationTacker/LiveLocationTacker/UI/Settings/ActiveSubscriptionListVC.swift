//
//  ActiveSubscriptionListVC.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 01/07/25.
//

import UIKit

class ActiveSubscriptionListVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var subscriptionCV: UICollectionView!
    @IBOutlet weak var btnManageScbscription: UIButton!
    @IBOutlet weak var noDataStackView: UIStackView!
    
    // MARK: - Properties
    var arrOfActivePlan : [PlanStatus] = []
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        subscriptionCV.register(UINib(nibName: ActiveSubscriptionCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: ActiveSubscriptionCVCell.identifier)
        subscriptionCV.register(UINib(nibName: ChangePlanButtonCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: ChangePlanButtonCVCell.identifier)
        getActivePlans()
    }
    
    // MARK: - Button Actions
    @IBAction func backClick(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func subscripPlanClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .subscription_click_subscribeplan)
        let vc = StoryboardScene.Settings.choosePlanVC.instantiate()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func manageSubscriptionClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .subscription_click_manageplan)
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - API Calls
    func getActivePlans(){
        showLoader(text: "Loading...")
        RevenueCatManager.shared.getCurrentPlanStatus { status in
            hideLoader()
            self.noDataStackView.isHidden = true
            self.btnManageScbscription.isHidden = false
            if status.count == 0 {
                print("No active plan.")
                self.noDataStackView.isHidden = false
                self.btnManageScbscription.isHidden = true
                return
            }
            self.arrOfActivePlan = status
            self.arrOfActivePlan.append(PlanStatus(productId: "", planDuration: "", productPrice: "", expirationDate: nil, isTrial: false, daysRemaining: 0, billType: ""))
            self.subscriptionCV.reloadData()
        }
    }
    // MARK: - OTHER
    
    // MARK: - DELEGATE
}

// MARK: - UICollectionView Delegate & DataSource Methods
extension ActiveSubscriptionListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrOfActivePlan.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < self.arrOfActivePlan.count - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActiveSubscriptionCVCell.identifier, for: indexPath) as! ActiveSubscriptionCVCell
            let data = self.arrOfActivePlan[indexPath.row]
            cell.data = data
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChangePlanButtonCVCell.identifier, for: indexPath) as! ChangePlanButtonCVCell
            cell.btnChangePlan.addTarget(self, action: #selector(changePlanButtonTapped(_ :)), for: .touchUpInside)
            return cell
        }
    }
    
    @objc func changePlanButtonTapped(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .subscription_click_changeplan)
        let vc = StoryboardScene.Settings.choosePlanVC.instantiate()
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
