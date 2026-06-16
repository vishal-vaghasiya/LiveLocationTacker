//
//  ChildModeMemberListVC.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 09/09/25.
//

import UIKit

class ChildModeMemberListVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTableTitle: UILabel!
    @IBOutlet weak var tblBGView: UIView!
    @IBOutlet weak var tblMember: UITableView!
    @IBOutlet weak var contTableHeight: NSLayoutConstraint!
    @IBOutlet weak var btnAddMember: UIButton!
    @IBOutlet weak var lblLearChildMode: UILabel!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    var circleInfo = CircleInfo()
    var arrOfUserInfo: [UserInfo] = []
    var removeMemberEvent: ((UserInfo) -> ())?
    var addMemberEvent: ((UserInfo) -> ())?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setNativeAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    
    func setup() {
        self.tblMember.register(UINib(nibName: ChildModeAddMemberCell.identifier, bundle: nil), forCellReuseIdentifier: ChildModeAddMemberCell.identifier)
        self.tblMember.delegate = self
        self.tblMember.dataSource = self
        self.fetchChildMembers()
    }
    
    func setupLocalization() {
        self.lblTitle.text = L10n.childMode
        self.btnAddMember.setTitle(L10n.addMember, for: .normal)
        self.lblTableTitle.text = L10n.ChildModeIsEnabledFor + " :"
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
    
    @IBAction func clickAddMember(_ sender: UIButton) {
        let vc = StoryboardScene.Child.childModeAddPopupVC.instantiate()
        vc.circleInfo = self.circleInfo
        vc.addMemberEvent = { newChildMember in
            self.circleInfo.childMember.append(newChildMember.phone)
            self.arrOfUserInfo.append(newChildMember)
            self.addMemberEvent?(newChildMember)
            self.reloadTBL()
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
    func reloadTBL(){
        if self.arrOfUserInfo.count == 0 {
            self.tblBGView.isHidden = true
            self.contTableHeight.constant = 1
        } else {
            self.tblBGView.isHidden = false
        }
        self.tblMember.reloadData()
    }
    
    // MARK: - API CALLING
    func fetchChildMembers() {
        let childNumbers = self.circleInfo.childMember
        
        let remainingMembers = childNumbers.filter {
            $0 != DefaultManager.User.PHONE
        }
        
        Loader.show("Loading...")
        FirebaseManager.shared.fetchUsersByPhoneNumbers(phoneNumbers: remainingMembers) { success, message, userInfos in
            Loader.hide()
            if success {
                // TODO: Handle userInfos (e.g., update UI or store data)
                print("✅ Members fetched: \(userInfos.count)")
                self.arrOfUserInfo = userInfos
                self.reloadTBL()
            } else {
                showToast(message: message)
                self.reloadTBL()
            }
        }
    }
    
    func removeChildMode(index: Int) {
        self.tblMember.isUserInteractionEnabled = false
        let data = self.arrOfUserInfo[index]
        FirebaseManager.shared.removeToChildCircle(from: self.circleInfo.code, childPhone: data.phone) { isRemove, error in
            if isRemove {
                self.removeMemberEvent?(data)
                self.arrOfUserInfo.remove(at: index)
                let tempArr = self.circleInfo.childMember.filter { $0 != data.phone }
                self.circleInfo.childMember = tempArr
                self.reloadTBL()
            }
            self.tblMember.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - DELEGATE

}

//MARK: - TABLEVIEW
extension ChildModeMemberListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfUserInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChildModeAddMemberCell.identifier, for: indexPath) as! ChildModeAddMemberCell
        let data = self.arrOfUserInfo[indexPath.row]
        cell.data = data
        cell.lblCricle.text = self.circleInfo.name
        cell.btnRemove.isHidden = false
        cell.sepretorView.isHidden = indexPath.row == (self.arrOfUserInfo.count - 1)
        cell.removeClickEvent = {
            let vc = StoryboardScene.Circle.commonAlertPopup.instantiate()
            let name = getFullName(firstName: data.firstName, lastName: data.lastName)
            vc.selectedPopType = .Disable_Child_Mode
            vc.userName = name
            vc.clickYesEvent = {
                self.removeChildMode(index: indexPath.row)
            }
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.arrOfUserInfo.count != 0 {
            main {
                self.contTableHeight.constant = self.tblMember.contentSize.height
            }
        }
    }
}
