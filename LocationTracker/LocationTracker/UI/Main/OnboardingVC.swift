//
//  OnboardingVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit

class OnboardingVC: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var onboardingCV: UICollectionView!
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    let onboardingData: [(image: String, title: String, subTitle: String)] = [
        (Asset.onboarding1.name, L10n.stayCloseToYourLovedOnes, L10n.familyConnected),
        (Asset.onboarding2.name, L10n.realTimeLocationAtYourFingertips, L10n.seeLiveUpdatesInstantlyAndNeverMissAMoment),
        (Asset.onboarding3.name, L10n.aSmarterWayToLocateFamily, L10n.quickAccessToRealTimeFamilyLocationsMadeSimple)
    ]
    var currentIndex = 0
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setNativeAd()
    }
    
    // MARK: - UI SETUP
    private func setupCollectionView() {
        onboardingCV.delegate = self
        onboardingCV.dataSource = self
        onboardingCV.isPagingEnabled = true
        
        onboardingCV.register(UINib(nibName: OnboardingCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCVCell.identifier)
    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
// MARK: - UICollectionView Delegate & DataSource
extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1//onboardingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCVCell.identifier, for: indexPath) as! OnboardingCVCell
        
        let data = onboardingData[currentIndex]
        cell.configure(imageName: data.image, title: data.title, subTitle: data.subTitle)
        cell.configurePageControl(currentPage: currentIndex, totalPages: onboardingData.count)
        
        // Handle Next button action
        cell.nextButtonAction = {
            let nextPage = self.currentIndex + 1
            if nextPage < self.onboardingData.count {
                FirebaseManager.shared.logAnalyticsEvent(name: nextPage == 0 ? .strat1_click_next : .start2_click_next)
                self.currentIndex = nextPage
                self.onboardingCV.reloadData()
                self.setNativeAd()
            } else {
                // Finish onboarding
                AdManager.shared.showInterstitialAd(from: self) {
                    FirebaseManager.shared.logAnalyticsEvent(name: .start3_click_next)
                    let vc = StoryboardScene.Permission.setupPermissionVC.instantiate()
                    vc.permissionType = .All
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        return cell
    }
    
    // Layout size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
