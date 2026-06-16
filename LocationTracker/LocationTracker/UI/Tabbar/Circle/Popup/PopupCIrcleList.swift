//
//  PopupCIrcleList.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit

class PopupCIrcleList: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var circleListTV: UITableView!
    @IBOutlet weak var btnCreateCircle: PrimaryButton!
    @IBOutlet weak var btnJoin: UIButton!
    
    // MARK: - PROPERTY
    var onClosedTapped: (() -> Void)?
    var onJoinCircleTapped: (() -> Void)?
    var onChangeCircleTapped: (([CircleInfo]) -> Void)?
    var onEditCircleTapped: ((CircleInfo) -> Void)?
    var arrOfCircle = [CircleInfo]()
    var clickCreateCircleEvent: (() -> ())?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        self.circleListTV.register(UINib(nibName: CircleTVCell.identifier, bundle: nil), forCellReuseIdentifier: CircleTVCell.identifier)
        self.setupButton()
    }
    
    func setupLocalization() {
        self.btnCreateCircle.setTitle(L10n.createCircle, for: .normal)
        self.btnJoin.setTitle(L10n.joinCircle, for: .normal)
    }
    
    func setupButton() {
        self.btnCreateCircle.isEnabled = true
        btnCreateCircle.setTitle(LocalizationKey.Create_Circle.text, for: .normal)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func closePopupClick(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.onClosedTapped?()
        }
    }
    
    @IBAction func clickCreateCircle(_ sender: PrimaryButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .circle_click_create)
        self.dismiss(animated: false) {
            self.clickCreateCircleEvent?()
        }
//        self.createNewGroupTapped()
    }
    
    @IBAction func joinCircleClick(_ sender: UIButton) {
        FirebaseManager.shared.logAnalyticsEvent(name: .circle_click_join)
        self.dismiss(animated: false) {
            self.onJoinCircleTapped?()
        }
    }
    
    // MARK: - OTHER
    func createNewGroupTapped() {
        let alert = UIAlertController(title: "Create New Circle", message: "Enter the name of your new circle.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Circle Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let circleName = alert.textFields?.first?.text, !circleName.isEmpty {
                Loader.show("Loading...")
                FirebaseManager.shared.createCircle(name: circleName) { success, message, data in
                    Loader.hide()
                    if success {
                        if let _ = data {
                            self.fetchAllCircle()
                        }
                    } else {
                        showToast(message: message)
                    }
                }
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
        FirebaseManager.shared.getMyCircle(completion: { success, message, data  in
            DispatchQueue.main.async {
                self.arrOfCircle = data
                AppData.shared.selectedCircleInfo = data.first
                self.circleListTV.reloadData()
            }
        })
    }
    
    // MARK: - DELEGATE
}
extension PopupCIrcleList: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfCircle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CircleTVCell.identifier, for: indexPath) as! CircleTVCell
        let data = arrOfCircle[indexPath.row]
        cell.data = data
        cell.clickEditEvent = {
            self.dismiss(animated: false) {
                self.onEditCircleTapped?(data)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupDicValue = arrOfCircle[indexPath.row]
        AppData.shared.selectedCircleInfo = groupDicValue
        DefaultManager.Cirlce.CURRENT_CODE = groupDicValue.code
        self.dismiss(animated: false) {
            self.onChangeCircleTapped?(self.arrOfCircle)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

