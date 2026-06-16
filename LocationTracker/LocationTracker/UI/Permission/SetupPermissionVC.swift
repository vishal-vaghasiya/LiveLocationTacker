//
//  SetupPermissionVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit

class SetupPermissionVC: UIViewController {
    
    // MARK: - OUTLET
    
    @IBOutlet weak var imgLogoAll: UIImageView!
    @IBOutlet weak var imgSingleLogo: UIImageView!
    
    @IBOutlet weak var locationCellView: UIView!
    @IBOutlet weak var notificationCellView: UIView!
    @IBOutlet weak var motionCellView: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblSharing: UILabel!
    @IBOutlet weak var lblCamera: UILabel!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var lblActivity: UILabel!
    
    @IBOutlet weak var continueButton: PrimaryButton!
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIButton!
    
    
    // MARK: - PROPERTY
    @IBOutlet var permissionSwitch: [TintedSwitch]!
    
    var permissionType: PermissionType = .All
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        self.setUpUI()
        setupPermissionSwitch()
        self.setBannerAds()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI SETUP
    
    func setUpUI() {
        self.imgLogoAll.isHidden = true
        self.imgSingleLogo.isHidden = true
        self.locationCellView.isHidden = true
        self.notificationCellView.isHidden = true
        self.motionCellView.isHidden = true
        self.btnBack.isHidden = true
        
        switch self.permissionType {
        case .All:
            self.imgLogoAll.isHidden = false
            self.locationCellView.isHidden = false
            self.notificationCellView.isHidden = false
            self.motionCellView.isHidden = false
            break
        case .Location_Sharing:
            self.imgSingleLogo.isHidden = false
            self.imgSingleLogo.image = Asset.logoPermissionLocationSharing.image
            self.locationCellView.isHidden = false
            self.btnBack.isHidden = false
            break
        case .Motion_Activity:
            self.imgSingleLogo.isHidden = false
            self.imgSingleLogo.image = Asset.logoPermissionMotionActivity.image
            self.motionCellView.isHidden = false
            self.btnBack.isHidden = false
            break
        }
        
    }
    
    func setupLocalization() {
        self.lblTitle.text = self.permissionType.title
        self.lblSubTitle.attributedText = self.permissionType.subTitle.lineSpacing(noOfLine: 3, alignment: .left)
        self.lblSharing.text = L10n.locationSharing
//        self.lblCamera.text = L10n.Access_Camera.text
        self.lblNotification.text = L10n.notification
        self.lblActivity.text = L10n.motionActivity
        self.continueButton.setTitle(L10n.`continue`, for: .normal)
    }
    
    func updateContinueButtonState() {
        if self.permissionType == .All {
            let allOn = permissionSwitch.allSatisfy { $0.isOn }
            self.continueButton.isEnabled = allOn
        } else {
            self.continueButton.isEnabled = true
        }
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
    
    func setupPermissionSwitch() {
        let dispatchGroup = DispatchGroup()

        for (index, sw) in permissionSwitch.enumerated() {
//            guard let type = AppPermissionType(rawValue: index) else { continue }
            guard let type = AppPermissionType(rawValue: sw.tag) else { continue }

            dispatchGroup.enter()

            AppPermissionManager.shared.checkPermission(type) { isGranted in
                DispatchQueue.main.async {
                    sw.isOn = isGranted
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.updateContinueButtonState()
        }
    }

    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigateBack()
    }
    
    @IBAction func allowPermissionSwitch(_ sender: TintedSwitch) {
        let tag = sender.tag
        guard let type = AppPermissionType(rawValue: tag) else { return }
        
        switch type {
        case .location:
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .permission_locationsharing_enable : .permission_locationsharing_disable)
        case .camera:
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .permission_acesscamera_enable : .permission_acesscamera_disable)
        case .notification:
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .permission_notification_enable : .permission_notification_disable)
        case .motion:
            FirebaseManager.shared.logAnalyticsEvent(name: sender.isOn ? .permission_motion_enable : .permission_motion_disable)
        }
        
        if sender.isOn {
            // Show alert directing user to Settings to disable permission
            AppPermissionManager.shared.requestPermission(for: type) { [weak self] granted in
                DispatchQueue.main.async {
                    sender.isOn = granted
                    self?.updateContinueButtonState()
                    if !granted {
                        self?.showSettingsAlert(for: type)
                    }
                }
            }
        } else {
            // User turned it off, show alert to go to settings
            showSettingsAlert(for: type)
            sender.isOn = AppPermissionManager.shared.isPermissionGranted(type)
            updateContinueButtonState()
        }
    }
    
    @IBAction func clickContinue(_ sender: PrimaryButton) {
        AdManager.shared.showInterstitialAd(from: self) {
            FirebaseManager.shared.logAnalyticsEvent(name: .permission_click_continue)
            if self.permissionType == .All {
                let vc = StoryboardScene.AuthFlow.phoneAuthVC.instantiate()
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.navigateBack()
            }
        }
    }
    
    // MARK: - OTHER
    func showSettingsAlert(for type: AppPermissionType) {
        let alert = UIAlertController(
            title: "\(type.displayName) Permission Required",
            message: "To continue, please enable \(type.displayName.lowercased()) permission in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        })
        present(alert, animated: true)
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    @objc func appDidBecomeActive() {
        setupPermissionSwitch()
    }
}
