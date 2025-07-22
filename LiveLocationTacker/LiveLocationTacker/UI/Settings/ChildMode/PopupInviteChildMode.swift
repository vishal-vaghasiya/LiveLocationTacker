//
//  PopupInviteChildMode.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 02/07/25.
//

import UIKit

class PopupInviteChildMode: UIViewController {

    // MARK: - OUTLET
    
    @IBOutlet weak var inviteStackView: UIStackView!
    
    @IBOutlet weak var circleInfoView: UIView!
    @IBOutlet weak var ivCircleImage: UIImageView!
    @IBOutlet weak var lblCircleName: UILabel!
    @IBOutlet weak var lblCircleOwner: UILabel!
    
    @IBOutlet weak var inviteModeStackView: UIStackView!
    
    @IBOutlet weak var enableModeStackView: UIStackView!
    @IBOutlet weak var joinCircleTV: UITableView!
    @IBOutlet weak var conJoinTVHeight: NSLayoutConstraint!

    @IBOutlet weak var circleListStackView: UIStackView!
    @IBOutlet weak var circleTV: UITableView!
    @IBOutlet weak var conTVHeight: NSLayoutConstraint!
    
    @IBOutlet weak var contBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIView!
    
    // MARK: - PROPERTY
    var selectedIndex = -1
    var firebaseManager = FirebaseManager.shared
    var arrOfCircle: [ChildModeCircleInfo] = []
    var arrOfEnableModeCircle: [CircleInfo] = []
    var circleInfo = CircleInfo()
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setBannerAds()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        self.circleTV.register(UINib(nibName: ChildModeCircleTVCell.identifier, bundle: nil), forCellReuseIdentifier: ChildModeCircleTVCell.identifier)
        self.circleTV.rowHeight = UITableView.automaticDimension
        self.joinCircleTV.register(UINib(nibName: ChildCircelTVCell.identifier, bundle: nil), forCellReuseIdentifier: ChildCircelTVCell.identifier)
        self.joinCircleTV.rowHeight = UITableView.automaticDimension
        
        showLoader(text: "Loading...")
        firebaseManager.getChildActiveCircle { success, message, data in
            if success {
                hideLoader()
                self.arrOfCircle = data
                self.inviteStackView.isHidden = true
                self.circleListStackView.isHidden = false
                self.setupCircleView()
            } else {
                self.firebaseManager.getJoinedCircle { success, message, data in
                    hideLoader()
                    if data.count == 0 { //INVITE MODE
                        self.lblCircleName.text = selectedCircleInfo?.name ?? ""
                        //selectedGroupsnapSort?.childSnapshot(forPath: FirebaseKeys.name).value as? String ?? ""
                        self.circleListStackView.isHidden = true
                        self.inviteStackView.isHidden = false
                    } else {
                        self.arrOfEnableModeCircle = data
                        self.inviteStackView.isHidden = false
                        self.circleListStackView.isHidden = true
                    }
                    
                    self.inviteModeStackView.isHidden = data.count != 0
                    self.circleInfoView.isHidden = data.count != 0
                    self.enableModeStackView.isHidden = data.count == 0
                    
                    self.setupInviteView()
                }
            }
        }
    }
    
    func setupInviteView() {
        self.joinCircleTV.reloadData()
    }
    
    func setupCircleView() {
        self.circleTV.reloadData()
    }
    
    // MARK: - Setup Ads
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
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func closeButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func inviteClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .childmode_click_invite)
        let vc = StoryboardScene.ChildMode.addMemberVC.instantiate()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    @IBAction func enableClick(_ sender: UIButton) {
        if selectedIndex < 0 { return }
        showLoader(text: "Updating...")
        let data = arrOfEnableModeCircle[self.selectedIndex]
        let childMode: [String: Any] = [
            FirebaseKeys.childMode: [
                FirebaseKeys.code: data.code,
                FirebaseKeys.enabled: 1,
                FirebaseKeys.ownerPhone: data.ownerPhone
            ]
        ]
        FirebaseManager.shared.logAnalyticsEvent(name: .childmode_click_enable)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.firebaseManager.updateUserData(updatedValues: childMode) { success, message in
                self.firebaseManager.joinChildCircle(inviteCode: data.code, completion: { (success, message) in
                    DefaultManager.User.IS_CHILD_MODE_ENABLE = true
                    hideLoader()
                    self.navigateToHome()
                })
            }
        })
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension PopupInviteChildMode: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == circleTV {
            return arrOfCircle.count
        }
        return arrOfEnableModeCircle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == circleTV {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChildModeCircleTVCell.identifier, for: indexPath) as! ChildModeCircleTVCell
            let data = arrOfCircle[indexPath.row]
            cell.data = data
            cell.ivArrow.image = self.selectedIndex == indexPath.row ? Asset.iconArrowWhiteUp.image : Asset.iconArrowWhiteDown.image
            cell.buttonView.isHidden = self.selectedIndex != indexPath.row
            cell.lineView.isHidden = (indexPath.row == (arrOfCircle.count - 1))
            
            cell.btnDisable.tag = indexPath.row
            cell.btnDisable.addTarget(self, action: #selector(disableChildModeCircle(_ :)), for: .touchUpInside)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ChildCircelTVCell.identifier, for: indexPath) as! ChildCircelTVCell
        let data = arrOfEnableModeCircle[indexPath.row]
        cell.data = data
        cell.ivArrow.isHidden = self.selectedIndex == indexPath.row
        cell.ivCircle.isHidden = !(self.selectedIndex == indexPath.row)
        cell.mainView.layer.borderColor = self.selectedIndex == indexPath.row ? Asset.color00BDFF.color.cgColor : UIColor.clear.cgColor
        return cell
    }
    
    @objc func disableChildModeCircle(_ sender: UIButton) {
        let data = arrOfCircle[sender.tag]
        firebaseManager.disableChildModeAndRemoveChild(fromCircleCode: data.code, childPhone: data.childPhone) { success, messsage in
            if success {
                showToastMessage(messsage)
                self.dismiss(animated: false)
            } else {
                showToastMessage(messsage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedIndex == indexPath.row {
            self.selectedIndex = -1
        } else {
            self.selectedIndex = indexPath.row
        }
        if tableView == circleTV {
            self.circleTV.reloadData()
            FirebaseManager.shared.logAnalyticsEvent(name: .childmode_click_setting)
        } else {
            FirebaseManager.shared.logAnalyticsEvent(name: .childmode_click_circle)
            self.joinCircleTV.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == circleTV {
            DispatchQueue.main.async(execute: {
                self.conTVHeight.constant = self.circleTV.contentSize.height
            })
        } else {
            DispatchQueue.main.async(execute: {
                self.conJoinTVHeight.constant = self.joinCircleTV.contentSize.height
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
