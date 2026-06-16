//
//  OnboardingCVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit

class OnboardingCVCell: UICollectionViewCell {
    
    // MARK: - OUTLETS
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var pageControl: PrimaryPageControl!
    @IBOutlet weak var nextButton: PrimaryButton!
    
    // MARK: - CALLBACK
    var nextButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
    }
    
    func configure(imageName: String, title: String, subTitle: String) {
        mainImageView.image = UIImage(named: imageName)
        titleLabel.text = title
        subTitleLabel.text = subTitle
        self.nextButton.setTitle(L10n.next, for: .normal)
    }
    
    func configurePageControl(currentPage: Int, totalPages: Int) {
        // Set total pages only once
        if pageControl.numberOfPages != totalPages {
            pageControl.numberOfPages = totalPages
        }
        // Animate page update
        pageControl.currentPage = currentPage
    }
    
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        nextButtonAction?()
    }
    
}
