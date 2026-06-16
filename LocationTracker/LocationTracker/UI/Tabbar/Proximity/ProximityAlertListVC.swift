//
//  ProximityAlertListVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 02/09/25.
//

import UIKit

class ProximityAlertListVC: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var proximityListTV: UITableView!
    @IBOutlet weak var addBtnView: UIView!
    @IBOutlet weak var lblAddBtn: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNoDataTitle: UILabel!
    
    // MARK: - PROPERTY
    var alerts: [ProximityAlert] = []
    var onAddButtonTapped: (() -> Void)?
    var onDidSelectTapped: ((ProximityAlert) -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Loader.show("")
        alerts = CoreDataManager.shared.fetchProximityAlerts()
        proximityListTV.isHidden = alerts.count == 0
        lblNoDataTitle.isHidden = alerts.count > 0
        addBtnView.isHidden = DefaultManager.User.IS_CHILD_MODE_ENABLE
        proximityListTV.reloadData()
        Loader.hide()
        setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        self.proximityListTV.showsVerticalScrollIndicator = false
        self.proximityListTV.register(UINib(nibName: ProximityTVCell.identifier, bundle: nil), forCellReuseIdentifier: ProximityTVCell.identifier)
    }
    
    func setupLocalization(){
        lblTitle.text = L10n.proximityAlert
        lblAddBtn.text = L10n.add
        lblNoDataTitle.text = L10n.addAProximityAlertToGetStarted
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func addNewAlertClick(_ sender: UIButton) {
        onAddButtonTapped?()
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension ProximityAlertListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProximityTVCell.identifier, for: indexPath) as! ProximityTVCell
        cell.data = alerts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < alerts.count else { return }
        let data = alerts[indexPath.row]
        onDidSelectTapped?(data)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}
