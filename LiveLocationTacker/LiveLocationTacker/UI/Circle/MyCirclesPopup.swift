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
    
    // MARK: - PROPERTY
    var groupSnapSortList = [DataSnapshot]()
    let firebaseManager = FirebaseManager.shared
    var selectedGroup:(([DataSnapshot])->Void)?
    var updateCircle:(([DataSnapshot])->Void)?
    var joinCircle:(()->Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func createCircleClick(_ sender: UIButton) {
        createNewGroupTapped()
    }
    
    @IBAction func joinCircleClick(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.joinCircle?()
        }
    }
    
    @IBAction func outerViewAction(_ sender: UIControl) {
        self.dismiss(animated: false) {
            self.updateCircle?(self.groupSnapSortList)
        }
    }
    
    // MARK: - OTHER
    func creatingNewCircle(name:String){
        showLoader(text: "Loading...")
        
//        UIDevice.current.isBatteryMonitoringEnabled = true
//        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
//        
//        firebaseManager.createCircle(name: name,
//                                     userName: DefaultManager.User.NAME,
//                                     countryCode: DefaultManager.User.COUNTRY_CODE,
//                                  userPhone: DefaultManager.User.PHONE,
//                                  batteryLevel: batteryLevel) { [self] generatedCode in
//            print("Share this code with your friend: \(generatedCode ?? "")")
//            self.hideLoader()
//            fetchAllCircle()
//        }
        
        firebaseManager.createCircle(name: name) { success, message, data in
            self.hideLoader()
            if success {
                if let _ = data {
                    self.fetchAllCircle()
                }
            } else {
                self.showToastMessage(message)
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
//        firebaseManager.saveFcmTokenFirebase()
//        firebaseManager.fetchAllCircles(phoneNumber: DefaultManager.User.PHONE) { ListSnapSort in
//            DispatchQueue.main.async {
//                self.groupSnapSortList = ListSnapSort
//                selectedGroupsnapSort = ListSnapSort.first
//                
//                self.groupTableview.reloadData()
//            }
//        }
        
        firebaseManager.getMyCircle(completion: { success,message,snapshot  in
            DispatchQueue.main.async {
                self.groupSnapSortList = snapshot
                selectedGroupsnapSort = snapshot.first
                self.groupTableview.reloadData()
            }
        })
    }
    
    // MARK: - DELEGATE
}
extension MyCirclesPopup: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupSnapSortList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupCell = tableView.dequeueReusableCell(withType: CircleListTBVCell.self)
        let groupDicValue = groupSnapSortList[indexPath.row]
        groupCell.lbl_name.text = groupDicValue.childSnapshot(forPath: FirebaseKeys.name).value as? String ?? ""
        groupCell.lbl_membercount.text = "\((groupDicValue.childSnapshot(forPath: FirebaseKeys.members).value as? [String:Any] ?? [:]).count) Members"
        return groupCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupDicValue = groupSnapSortList[indexPath.row]
        selectedGroupsnapSort = groupDicValue
        DefaultManager.Cirlce.CURRENT_CODE = selectedGroupsnapSort?.childSnapshot(forPath: "code").value as? String ?? ""
        self.dismiss(animated: false) {
            self.selectedGroup?(self.groupSnapSortList)
        }
    }
}
