//
//  MyCirclesPopup.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 27/06/25.
//

import UIKit
import FirebaseDatabase

class MyCirclesPopup: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var groupTableview: UITableView!
    @IBOutlet weak var createJoinBtnView: UIStackView!
    
    // MARK: - PROPERTY
    var arrOfCircle = [CircleInfo]()
    let firebaseManager = FirebaseManager.shared
    var selectedGroup:(([CircleInfo])->Void)?
    var updateCircle:(([CircleInfo])->Void)?
    var joinCircle:(()->Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if DefaultManager.IS_SUBSCRIPTION {
            self.createJoinBtnView.isHidden = false
        } else {
            self.createJoinBtnView.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE || self.arrOfCircle.count >= 2
        }
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func createCircleClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .circle_click_create)
        createNewGroupTapped()
    }
    
    @IBAction func joinCircleClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .circle_click_join)
        self.dismiss(animated: false) {
            self.joinCircle?()
        }
    }
    
    @IBAction func outerViewAction(_ sender: UIControl) {
        self.dismiss(animated: false) {
            self.updateCircle?(self.arrOfCircle)
        }
    }
    
    // MARK: - OTHER
    func creatingNewCircle(name:String){
        showLoader(text: "Loading...")
        firebaseManager.createCircle(name: name) { success, message, data in
            hideLoader()
            if success {
                if let _ = data {
                    self.fetchAllCircle()
                }
            } else {
                showToastMessage(message)
            }
        }
    }
    
    func createNewGroupTapped() {
        let alert = UIAlertController(title: "Create New Circle", message: "Enter the name of your new circle.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Circle Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let circleName = alert.textFields?.first?.text, !circleName.isEmpty {
                print("New Circle Name: \(circleName)")
                self.creatingNewCircle(name: circleName)
            }
            else {
                print("Circle name cannot be empty.")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - API CALLING
    func fetchAllCircle() {
        firebaseManager.getMyCircle(completion: { success, message, data  in
            DispatchQueue.main.async {
                self.arrOfCircle = data
                selectedCircleInfo = data.first
                self.groupTableview.reloadData()
            }
        })
    }
    
    // MARK: - DELEGATE
}
extension MyCirclesPopup: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfCircle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupCell = tableView.dequeueReusableCell(withType: CircleListTBVCell.self)
        let data = arrOfCircle[indexPath.row]
        groupCell.lbl_name.text = data.name
        groupCell.lbl_membercount.text = "\(data.members.count) Members"
        return groupCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupDicValue = arrOfCircle[indexPath.row]
        selectedCircleInfo = groupDicValue
        DefaultManager.Cirlce.CURRENT_CODE = selectedCircleInfo?.code ?? ""
        self.dismiss(animated: false) {
            self.selectedGroup?(self.arrOfCircle)
        }
    }
}
