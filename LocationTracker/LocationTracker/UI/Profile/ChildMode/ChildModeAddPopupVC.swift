//
//  ChildModeAddPopupVC.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 09/09/25.
//

import UIKit

class ChildModeAddPopupVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var memberTbl: UITableView!
    @IBOutlet weak var contTblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblNoData: UILabel!
    
    // MARK: - PROPERTY
    var circleInfo = CircleInfo()
    var arrOfUserInfo: [UserInfo] = []
    var addMemberEvent: ((UserInfo) -> ())?
    
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
        self.fetchRemainingMembers()
        self.memberTbl.register(UINib(nibName: ChildModeAddMemberCell.identifier, bundle: nil), forCellReuseIdentifier: ChildModeAddMemberCell.identifier)
        self.memberTbl.delegate = self
        self.memberTbl.dataSource = self
    }
    
    func setupLocalization() {
        self.lblTitle.text = L10n.addMember + " :"
        self.lblNoData.text = L10n.noMembers
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    // MARK: - OTHER
    
    func reloadTBL(){
        if self.arrOfUserInfo.count == 0 {
            self.lblNoData.isHidden = false
            self.contTblHeight.constant = 128
        }
        self.memberTbl.reloadData()
    }
    
    // MARK: - Fetch Remaining Members
    func fetchRemainingMembers() {
        let childNumbers = self.circleInfo.childMember
        let members = self.circleInfo.members
        
        let remainingMembers = members.filter {
            !childNumbers.contains($0) && $0 != DefaultManager.User.PHONE
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
    
    // MARK: - API CALLING
    func addChildMode(index: Int) {
        self.memberTbl.isUserInteractionEnabled = false
        
        /*let data = circleInfo
        let childMode: [String: Any] = [
            FirebaseKeys.childMode: [
                FirebaseKeys.code: data.code,
                FirebaseKeys.enabled: 1,
                FirebaseKeys.ownerPhone: data.ownerPhone
            ]
        ]
        FirebaseManager.shared.logAnalyticsEvent(name: .childmode_click_enable)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            FirebaseManager.shared.updateUserData(updatedValues: childMode) { success, message in

            }
        })*/
        
        let data = self.arrOfUserInfo[index]
        FirebaseManager.shared.addToChildCircle(from: self.circleInfo.code, childPhone: data.phone) { isAdd, error in
            if isAdd {
                self.addMemberEvent?(data)
                self.arrOfUserInfo.remove(at: index)
                self.reloadTBL()
            }
            self.memberTbl.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - DELEGATE
}

//MARK: - TABLEVIEW
extension ChildModeAddPopupVC: UITableViewDelegate, UITableViewDataSource {
    
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
        cell.btnAdd.isHidden = false
        cell.sepretorView.isHidden = indexPath.row == (self.arrOfUserInfo.count - 1)
        cell.addClickEvent = {
            self.addChildMode(index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.arrOfUserInfo.count != 0 {
            main {
                self.contTblHeight.constant = self.memberTbl.contentSize.height
            }
        }
    }
}
