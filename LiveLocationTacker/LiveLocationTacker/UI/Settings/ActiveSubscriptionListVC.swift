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
    
    // MARK: - Properties
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        subscriptionCV.register(UINib(nibName: "ActiveSubscriptionCVCell", bundle: nil), forCellWithReuseIdentifier: "ActiveSubscriptionCVCell")
        subscriptionCV.register(UINib(nibName: "ChangePlanButtonCVCell", bundle: nil), forCellWithReuseIdentifier: "ChangePlanButtonCVCell")
    }
    
    // MARK: - Button Actions
    @IBAction func backClick(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func manageSubscriptionClick(_ sender: UIButton) {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - API Calls
    
    // MARK: - OTHER
    
    // MARK: - DELEGATE
}

// MARK: - UICollectionView Delegate & DataSource Methods
extension ActiveSubscriptionListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActiveSubscriptionCVCell", for: indexPath) as! ActiveSubscriptionCVCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChangePlanButtonCVCell", for: indexPath) as! ChangePlanButtonCVCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: view.frame.width - 30, height: 202)
        }
        return CGSize(width: collectionView.frame.width, height: 55)
    }
}
