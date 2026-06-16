//
//  MemberVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 06/08/25.
//

import UIKit

class MemberVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var memberTV: UITableView!
    @IBOutlet weak var addBtnView: UIView!
    @IBOutlet weak var lblAddBtn: UILabel!
    
    // MARK: - PROPERTY
    var onAddMemberTapped: (() -> Void)?
    var onUserLocationTapped: ((UserInfo) -> Void)?
    var arrOfMember: [UserInfo] = []
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top corners only
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        self.memberTV.register(UINib(nibName: MemberTVCell.identifier, bundle: nil), forCellReuseIdentifier: MemberTVCell.identifier)
        self.addBtnView.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE
    }
    
    func setupLocalization() {
        self.lblTitle.text = L10n.members
        self.lblAddBtn.text = L10n.add
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func addMemberClick(_ sender: UIButton) {
        onAddMemberTapped?()
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension MemberVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfMember.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MemberTVCell.identifier, for: indexPath) as! MemberTVCell
        let data = arrOfMember[indexPath.row]
        cell.data = data
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.arrOfMember[indexPath.row]
        if DefaultManager.User.IS_CHILD_MODE_ENABLE && data.phone != DefaultManager.User.PHONE { return }
        onUserLocationTapped?(data)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}
