//
//  MainTabBarController.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 06/08/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: - OUTLET
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        let font = FontFamily.Poppins.medium.font(size: 14)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupTabNames()
    }
    
    // MARK: - UI SETUP
    func setupTabNames() {
        if let tabItems = self.tabBar.items, tabItems.count >= 3 {
            tabItems[0].title = L10n.map
            tabItems[1].title = L10n.proximity
            tabItems[2].title = L10n.settings
        }
    }
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}

class CustomTabBar : UITabBar {

@IBInspectable var height: CGFloat = 65.0

override open func sizeThatFits(_ size: CGSize) -> CGSize {
    guard let window = UIApplication.shared.connectedScenes
        .compactMap({$0 as? UIWindowScene})
        .first?.windows
        .filter({$0.isKeyWindow}).first else {
      return super.sizeThatFits(size)
    }
    var sizeThatFits = super.sizeThatFits(size)
    if height > 0.0 {
        
        if #available(iOS 11.0, *) {
            sizeThatFits.height = height + window.safeAreaInsets.bottom
        } else {
            sizeThatFits.height = height
        }
    }
    return sizeThatFits
}
}
