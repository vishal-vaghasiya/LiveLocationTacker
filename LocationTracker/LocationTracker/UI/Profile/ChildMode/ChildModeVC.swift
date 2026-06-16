//
//  ChildModeVC.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 09/09/25.
//

import UIKit

class ChildModeVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var ivCircleImage: UIImageView!
    @IBOutlet weak var lblCircleName: UILabel!
    @IBOutlet weak var lblCircleOwner: UILabel!
    
    @IBOutlet weak var addChildModeView: UIView!
    @IBOutlet weak var lblChildModeTitle: UILabel!
    @IBOutlet weak var lblChildModeSubTitle: UILabel!
    @IBOutlet weak var btnAddMember: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var lbllocation: UILabel!
    @IBOutlet weak var lblBettry: UILabel!
    @IBOutlet weak var lblLogout: UILabel!
    @IBOutlet weak var lblLearChildMode: UILabel!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    var selectedIndex = -1
    //var arrOfCircle: [ChildModeCircleInfo] = []
    //var arrOfEnableModeCircle: [CircleInfo] = []
    var circleInfo = CircleInfo()
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        setNativeAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
        self.setupData()
    }
    
    // MARK: - UI SETUP
    
    func setupUI() {
//        Loader.show("Loading...")
//        FirebaseManager.shared.getChildActiveCircle { success, message, data in
//            if success {
//                Loader.hide()
//                self.arrOfCircle = data
//                self.addChildModeView.isHidden = true
//            } else {
//                FirebaseManager.shared.getJoinedCircle { success, message, data in
//                    Loader.hide()
//                    if data.count == 0 { //INVITE MODE
//                        self.lblCircleName.text = AppData.shared.selectedCircleInfo?.name ?? ""
//                    } else {
//                        self.arrOfEnableModeCircle = data
//                    }
//                    self.addChildModeView.isHidden = data.count != 0
//                }
//            }
//        }
        self.lblCircleName.text = self.circleInfo.name
    }
    
    func setupData() {
        self.addChildModeView.isHidden = self.circleInfo.members.count <= 1
    }
    
    func setupLocalization() {
        self.lblTitle.text = L10n.childMode
        self.lblCircleOwner.text = L10n.circleOwner
        self.lblChildModeTitle.text = L10n.SetupChildMode
        self.lblChildModeSubTitle.attributedText = L10n.addChildToACircleAndAnableChildModeInTheAppSettingsOnTheirDevice.lineSpacing(noOfLine: 3, alignment: .left)
        self.lblDescription.attributedText = L10n.yourChildrenWontBeAbleToCreatingCirclesBrowsingTravelHistoryTurnOffLocationAndBatteryLevelSharingOrLogout.lineSpacing(noOfLine: 3, alignment: .left)
        self.btnAddMember.setTitle(L10n.addMember, for: .normal)
        self.lbllocation.text = L10n.locationSharing
        self.lblBettry.text = L10n.batteryLevelSharing
        self.lblLogout.text = L10n.logOut
        self.lblLearChildMode.text = L10n.LearnMoreAboutChildMode
    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigateBack()
    }
    
    @IBAction func clickProfile(_ sender: UIButton) {
        if self.circleInfo.childMember.count != 0 {
            AdManager.shared.showInterstitialAd(from: self) {
                let vc = StoryboardScene.Child.childModeMemberListVC.instantiate()
                vc.circleInfo = self.circleInfo
                vc.removeMemberEvent = { removeChild in
                    let tempArr = self.circleInfo.childMember.filter { $0 != removeChild.phone }
                    self.circleInfo.childMember = tempArr
                }
                vc.addMemberEvent = { newChildMember in
//                    self.circleInfo.childMember.append(newChildMember.phone)
                    self.setupData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func clickAddMember(_ sender: UIButton) {
        let vc = StoryboardScene.Child.childModeAddPopupVC.instantiate()
        vc.circleInfo = self.circleInfo
        vc.addMemberEvent = { newChildMember in
            self.circleInfo.childMember.append(newChildMember.phone)
            self.setupData()
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @IBAction func clickLearnMode(_ sender: UIButton) {
        AdManager.shared.showInterstitialAd(from: self) {
            let vc = StoryboardScene.Child.aboutChildModeVC.instantiate()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
