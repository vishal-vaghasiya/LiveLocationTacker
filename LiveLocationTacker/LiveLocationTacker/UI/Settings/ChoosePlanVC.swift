//
//  ChoosePlanVC.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 01/07/25.
//

import UIKit
import ProgressHUD
import RevenueCat

class ChoosePlanVC: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var planCV: UICollectionView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnContinue: UIEnableDisable!
    
    @IBOutlet weak var btnTermofuse: UIButton!
    @IBOutlet weak var btnPrivacy: UIButton!
    @IBOutlet weak var btnRestore: UIButton!
    
    // MARK: - PROPERTY
    let transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    var selectIndexB = false
    var selectIndex = Int()
    var hasAutoScrolled = false
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAutoScrolled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.planCV.reloadData()
                self.planCV.layoutIfNeeded()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.simulateDragThroughAllIndexes()
                }
            }
        }
    }
    
    func simulateDragThroughAllIndexes() {
        let totalItems = planCV.numberOfItems(inSection: 0)
        guard totalItems > 0 else { return }
        
        hasAutoScrolled = true
        
        let layout = planCV.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = planCV.frame.width / 1.5 + layout.minimumLineSpacing
        
        let group = DispatchGroup()
        
        for i in 0..<totalItems + 1 {
            group.enter()
            let delay = Double(i) * 0.3
            if totalItems == i {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let offsetX = CGFloat(1) * cellWidthIncludingSpacing - self.planCV.contentInset.left
                    let targetContentOffset = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
                    targetContentOffset.initialize(to: CGPoint(x: offsetX, y: 0))
                    self.planCV.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.scrollViewWillEndDragging(self.planCV, withVelocity: .zero, targetContentOffset: targetContentOffset)
                        targetContentOffset.deallocate()
                        group.leave()
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let offsetX = CGFloat(i) * cellWidthIncludingSpacing - self.planCV.contentInset.left
                    let targetContentOffset = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
                    targetContentOffset.initialize(to: CGPoint(x: offsetX, y: 0))
                    self.planCV.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.scrollViewWillEndDragging(self.planCV, withVelocity: .zero, targetContentOffset: targetContentOffset)
                        targetContentOffset.deallocate()
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.planCV.isHidden = false
            }
        }
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        self.planCV.isHidden = true
        self.btnContinue.isEnabled = true
        self.btnClose.isHidden = true
        self.planCV.register( UINib(nibName: "PlanCVCell", bundle: nil), forCellWithReuseIdentifier: "PlanCVCell")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.btnClose.isHidden = false
        })
    }
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func closeButtonClick(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnRestoreAction(_ sender: UIButton) {
        ProgressHUD.animate(interaction: false)
        Purchases.shared.restorePurchases { (purchaserInfo, error) in
            ProgressHUD.dismiss()
            if let error = error {
                //self.present(self.errorAlert(message: error.localizedDescription), animated: true, completion: nil)
            }
            self.refreshUserDetails()
        }
    }
    
    @IBAction func btnSubscribeAction(_ sender: UIButton) {
        //        for i in 0..<(self.offering?.availablePackages.count ?? 0) {
        //            if img_bg_week.isHighlighted == true {
        //                if offering?.availablePackages[i].packageType == .weekly {
        //                    buyProduct(index: i)
        //                }
        //            }
        //            else if img_bg_month.isHighlighted == true {
        //                if offering?.availablePackages[i].packageType == .monthly {
        //                    buyProduct(index: i)
        //                }
        //            }
        //            else if img_bg_year.isHighlighted == true {
        //                if offering?.availablePackages[i].packageType == .annual {
        //                    buyProduct(index: i)
        //                }
        //            }
        //        }
    }
    
    @IBAction func btnPrivacyPolicyAction(_ sender: UIButton) {
        guard let url = URL(string: PRIVACY) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnTermofUseAction(_ sender: UIButton) {
        guard let url = URL(string: TERMS) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - OTHER
    func refreshUserDetails() {
        //        Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
        //            if purchaserInfo?.entitlements[Constants.entitlementID]?.isActive == true {
        ////                Constants.USERDEFAULTS.set(true, forKey: "pro")
        //                DefaultManager.IS_SUBSCRIPTION = true
        //
        //                // Create the alert controller
        //                let alertController = UIAlertController(title: "Restore complete", message: "your sub restored", preferredStyle: .alert)
        //
        //                let okAction = UIAlertAction(title: "ok", style: .default) {
        //                    UIAlertAction in
        //                    if self.isFromTrailProScreen == true{
        //                        self.dismiss(animated: true) {
        //                            self.takingPremuium()
        //                        }
        //                    }
        //                    else{
        //                        self.navigateToHome()
        //                    }
        //                }
        //                alertController.addAction(okAction)
        //                self.present(alertController, animated: true, completion: nil)
        //            }
        //            else {
        //                self.showAlert(title: "no subcribe availble", message: "plz subcribe first")
        //                //Constants.USERDEFAULTS.removeObject(forKey: "pro")
        //                DefaultManager.IS_SUBSCRIPTION = false
        //            }
        //        }
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
extension ChoosePlanVC: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlanCVCell", for: indexPath) as! PlanCVCell

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
        self.selectIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.size.width/1.5
        let h = collectionView.frame.size.height
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth = collectionView.frame.width / 1.5
        let insetX = (collectionView.frame.width - cellWidth) / 2
        return UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth: Float = Float(planCV.bounds.width/1.5 + 10)
        let currentOffset: Float = Float(scrollView.contentOffset.x)
        let targetOffset: Float = Float(targetContentOffset.pointee.x)
        var newTargetOffset: Float = 0
        
        if targetOffset > currentOffset {
            newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
        }else {
            newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
        }
        
        if newTargetOffset < 0 {
            newTargetOffset = 0
        }else if (newTargetOffset > Float(scrollView.contentSize.width)){
            newTargetOffset = Float(Float(scrollView.contentSize.width))
        }
        
        targetContentOffset.pointee.x = CGFloat(currentOffset)
        scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: scrollView.contentOffset.y), animated: true)
        
        // Make Transition Effects for cells
        let duration = 0.2
        var index = newTargetOffset / pageWidth
        self.selectIndex = Int(index)
        
        for visibleCell in self.planCV.visibleCells {
            if let cell = visibleCell as? PlanCVCell,
               let indexPath = self.planCV.indexPath(for: cell) {
                
                cell.lblPrice.textColor = indexPath.row == self.selectIndex ? Asset.color00BDFF.color : Asset.colorFFFFFF.color
                cell.ivSelection.image = indexPath.row == self.selectIndex ? Asset.iconTickCircleSelected.image : Asset.iconTickCircle.image
                cell.ivLocation.image = indexPath.row == self.selectIndex ? Asset.iconPremiumLocation.image : Asset.iconPremiumLocationDisable.image
                cell.ivNotification.image = indexPath.row == self.selectIndex ? Asset.iconPremiumNotification.image : Asset.iconPremiumNotificationDisable.image
                cell.ivBattery.image = indexPath.row == self.selectIndex ? Asset.iconPremiumBattery.image : Asset.iconPremiumBatteryDisable.image
                cell.ivNoAds.image = indexPath.row == self.selectIndex ? Asset.iconPremiumNoAds.image : Asset.iconPremiumNoAdsDisable.image
                
            }
        }
        
        let cell = self.planCV.cellForItem(at: IndexPath(row: Int(index), section: 0))!
        if (index == 0){ // If first index
            animation(duration: duration, cell: cell as! PlanCVCell)
            
            index += 1
            if let cell = self.planCV.cellForItem(at: IndexPath(row: Int(index), section: 0)){
                animation1(duration: duration, cell: cell as! PlanCVCell)
            }
        }else{
            animation(duration: duration, cell: cell as! PlanCVCell)
            
            index -= 1// left
            if let cell = self.planCV.cellForItem(at: IndexPath(row: Int(index), section: 0)) {
                animation1(duration: duration, cell: cell as! PlanCVCell)
            }
            
            index += 1
            index += 1// right
            if let cell = self.planCV.cellForItem(at: IndexPath(row: Int(index), section: 0)) {
                animation1(duration: duration, cell: cell as! PlanCVCell)
            }
        }
    }
    
    func animation1(duration:Double,cell:PlanCVCell){
        UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
            cell.transform = self.transform
        }, completion: nil)
    }
    
    func animation(duration:Double,cell:PlanCVCell){
        UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
            cell.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    //    func reloadDateWhenAnimated1(cell:PlanCVCell){
    //        selectIndexB = false
    //        animation(duration: 0.0, cell: cell)
    //    }
    
}
