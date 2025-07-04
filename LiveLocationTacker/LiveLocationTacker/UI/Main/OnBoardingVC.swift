//
//  OnBoardingVC.swift
//  ScreenMirroring
//
//  Created by DREAMWORLD on 13/09/24.
//

import UIKit



class OnBoardingVC: UIViewController {
    
    @IBOutlet weak var bottom_view: UIView!
    @IBOutlet weak var btnNext: UIButton!
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
        
        self.btnNext.setButtonTitleAndFunctionality("Next")
        
//        bottom_view.addShadow()
//        bottom_view.makeTopCornerRound(20)
    }
    
    @IBAction func btnNextAction(_ sender: UIButton) {
        if pagerView.currentIndex == self.introTitle.count - 1 {
            let vc = StoryboardScene.Main.permissionVC.instantiate()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
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
        
        if pagerView.currentIndex == self.introTitle.count - 1 {
            self.btnNext.setButtonTitleAndFunctionality("Next"/*"Lets get"*/)
        }
        else {
            self.btnNext.setButtonTitleAndFunctionality("Next")
        }
    }
}
