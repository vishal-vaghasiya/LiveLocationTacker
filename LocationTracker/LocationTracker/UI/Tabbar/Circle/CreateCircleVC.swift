//
//  CreateCircleVC.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 03/09/25.
//

import UIKit

class CreateCircleVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCircleName: UILabel!
    @IBOutlet weak var txtCircleName: UITextField!
    @IBOutlet weak var circletxtBGView: UIView!
    
    @IBOutlet weak var lblLnvitationTitle: UILabel!
    @IBOutlet weak var lblInviteCode: UILabel!
    
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var lblMemeberTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var memberTBL: UITableView!
    @IBOutlet weak var contMemberTblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnCreate: PrimaryButton!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    var isEdit: Bool = false
    var backEvent: (() -> ())?
    var circleInfo: CircleInfo?
    var arrOfMember: [UserInfo] = []
    var removePhone:[String] = []
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    
    func setup() {
        self.memberTBL.delegate = self
        self.memberTBL.dataSource = self
        self.memberView.isHidden = !self.isEdit
        self.btnAdd.isHidden = true
        self.memberTBL.register(UINib(nibName: CreateCircleMemberCell.identifier, bundle: nil), forCellReuseIdentifier: CreateCircleMemberCell.identifier)
        self.memberTBL.reloadData()
        self.txtCircleName.addTarget(self, action: #selector(changeValue(_:)), for: .editingChanged)
        
        if isEdit {
            self.txtCircleName.text = circleInfo?.name
            self.lblInviteCode.text = circleInfo?.code
            self.btnCreate.isEnabled = false
            self.getMemberList()
        } else {
            let code = UUID().uuidString.prefix(6).uppercased()
            self.lblInviteCode.text = code
            self.setupContinueButton()
        }
        self.setNativeAd()
    }
    
    func setupLocalization() {
        self.btnCreate.setTitle(self.isEdit ? L10n.save : L10n.create, for: .normal)
        self.lblTitle.text = isEdit ? L10n.editCircle : L10n.createCircle
        self.lblCircleName.text = L10n.circleName
        self.txtCircleName.placeholder = L10n.enterCircleName
        self.lblLnvitationTitle.text = L10n.invitationCode
        self.lblMemeberTitle.text = L10n.members
        self.btnAdd.setTitle(L10n.add, for: .normal)
    }
    
    func setupContinueButton() {
        self.btnCreate.isEnabled = self.txtCircleName.text?.count != 0
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
        self.backEvent?()
    }
    
    @IBAction func clickCopyInviteCode(_ sender: UIButton) {
        copyToClipboard(text: self.lblInviteCode.text ?? "")
    }
    
    @IBAction func clickAddMember(_ sender: UIButton) {
        AdManager.shared.showInterstitialAd(from: self) {
            let vc = StoryboardScene.Circle.addMemberVC.instantiate()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func clickTextField(_ sender: UITextField) {
        if sender == self.txtCircleName {
            self.circletxtBGView.borderColor = Asset.appMain.color
        }
    }
    
    @IBAction func clickEndTextField(_ sender: UITextField) {
        if sender == self.txtCircleName {
            self.circletxtBGView.borderColor = Asset.appLightGrey.color
        }
    }
    
    @IBAction func createCircleClick(_ sender: PrimaryButton) {
        self.view.endEditing(true)
        self.btnCreate.isEnabled = false
        if isEdit {
            Loader.show("Loading...")
            FirebaseManager.shared.updateCircle(code: self.lblInviteCode.text ?? "", name: self.txtCircleName.text ?? "") { success, message in
                Loader.hide()
                showToast(message: message)
            }
            return
        }
        FirebaseManager.shared.logAnalyticsEvent(name: .circle_click_create)
        Loader.show("Loading...")
        FirebaseManager.shared.createCircle(name: txtCircleName.text ?? "") { success, message, data in
            Loader.hide()
            if success {
                self.navigateBack()
            } else {
                showToast(message: message)
            }
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    func getMemberList() {
        Loader.show("Loading...")
        DefaultManager.Cirlce.CURRENT_CODE = AppData.shared.selectedCircleInfo?.code ?? ""
        if let phoneNumbers = AppData.shared.selectedCircleInfo?.members as? [String] {
            FirebaseManager.shared.fetchUsersData(phoneNumbers: phoneNumbers) { result in
                Loader.hide()
                switch result {
                case .success(let users):
                    self.arrOfMember = parseUsers(from: users)
                    self.memberTBL.reloadData()
                case .failure(_):
                    self.arrOfMember.removeAll()
                    self.memberTBL.reloadData()
                }
            }
        } else {
            Loader.hide()
            self.arrOfMember.removeAll()
            self.memberTBL.reloadData()
        }
    }
    
    // MARK: - DELEGATE
    @objc func changeValue(_ textField: UITextField) {
        setupContinueButton()
    }
}

//MARK: - TABLEVIEW
extension CreateCircleVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfMember.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreateCircleMemberCell.identifier, for: indexPath) as! CreateCircleMemberCell
        let data = arrOfMember[indexPath.row]
        cell.data = data
        cell.btnRemove.isHidden = data.phone == DefaultManager.User.PHONE
        cell.clickCloseEvent = {
            let vc = StoryboardScene.Circle.commonAlertPopup.instantiate()
            vc.selectedPopType = .Remove_Member
            vc.clickYesEvent = {
                FirebaseManager.shared.removeMember(code: self.lblInviteCode.text ?? "", phone: data.phone) { success, message in
                    showToast(message: message)
                    if success {
                        self.arrOfMember.remove(at: indexPath.row)
                        self.memberTBL.reloadData()
                    }
                }
            }
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        main {
            self.contMemberTblHeight.constant = self.memberTBL.contentSize.height
        }
    }
}
