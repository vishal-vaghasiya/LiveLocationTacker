//
//  OnBoardingVC.swift
//  ScreenMirroring
//
//  Created by DREAMWORLD on 13/09/24.
//

import UIKit
class OnBoardingVC: UIViewController {
    
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bottom_view: UIView!
    @IBOutlet weak var btnNext: UIEnableDisable!
    @IBOutlet weak var pageControl: FSPageControl!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet{
            self.pagerView.register(UINib(nibName: "OnboardingFSPagerviewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        }
    }
    
    var introTitle = [
        "Stay in touch with your loved ones",
        "Track Updated Location",
        "Faster Way to get relatives location"
    ]
    
    var intoImage = ["onboard_1","onboard_2","onboard_3"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: - Do any additional setup after loading the view.
        
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.transformer = FSPagerViewTransformer(type: .crossFading)

        //MARK: - PageController Initialize
        
        pageControl.numberOfPages = self.introTitle.count
        pageControl.currentPage = 0
        pageControl.interitemSpacing = 20
        pageControl.contentHorizontalAlignment = .fill
        pageControl.setImage(UIImage.init(named: "pagecontrol_unselect"), for: .normal)
        pageControl.setImage(UIImage.init(named: "pagecontrol_select"), for: .selected)
        
        self.btnNext.isEnabled = true
        self.setBannerAds()
     }
    
    func setBannerAds() {
        AdManager.shared.loadBannerAd(in: self.bannerView, rootViewController: self) { isShow in
            if isShow {
                UIView.animate(withDuration: 0.5) {
                    self.contBannerHeight.constant = 50
                    self.view.layoutIfNeeded()
                }
            } else {
                self.contBannerHeight.constant = 0
            }
        }
    }
    
    @IBAction func btnNextAction(_ sender: UIButton) {
        
        if pagerView.currentIndex == self.introTitle.count - 1 {
            AdManager.shared.showInterstitialAd(from: self) {
                FirebaseManager.shared.logAnalyticsEvent(name: .start3_click_next)
                let vc = StoryboardScene.Main.permissionVC.instantiate()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else{
            FirebaseManager.shared.logAnalyticsEvent(name: pagerView.currentIndex == 0 ? .strat1_click_next : .start2_click_next)
            let nextIndex = pagerView.currentIndex + 1 < numberOfItems(in:self.pagerView) ? pagerView.currentIndex + 1 : 0
            
            self.pagerView.scrollToItem(at: nextIndex, animated: true)
        }
    }
}


//MARK: - FSPagerView Delegate and Datasource -

extension OnBoardingVC : FSPagerViewDelegate, FSPagerViewDataSource {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.introTitle.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = self.pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! OnboardingFSPagerviewCell
        cell.image_view.image = UIImage(named: intoImage[index])
        cell.image_view.contentMode = .scaleAspectFit
        cell.lbl_title.text = introTitle[index]
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
       return false
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
}
