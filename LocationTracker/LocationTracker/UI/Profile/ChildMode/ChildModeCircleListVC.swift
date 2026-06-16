//
//  ChildModeCircleListVC.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 10/09/25.
//

import UIKit

class ChildModeCircleListVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var circleTbl: UITableView!
    @IBOutlet weak var contTblHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    var arrOfCricle: [CircleInfo] = []
    var selectedCricle: CircleInfo = CircleInfo()
    var circleSelectEvent: ((CircleInfo) -> ())?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    // MARK: - UI SETUP
    func setup() {
        self.circleTbl.register(UINib(nibName: ChildModeCircleListCell.identifier, bundle: nil), forCellReuseIdentifier: ChildModeCircleListCell.identifier)
        self.circleTbl.delegate = self
        self.circleTbl.dataSource = self
        self.circleTbl.reloadData()
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}

//MARK: - TABLEVIEW
extension ChildModeCircleListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfCricle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChildModeCircleListCell.identifier, for: indexPath) as! ChildModeCircleListCell
        let data = self.arrOfCricle[indexPath.row]
        cell.data = data
        self.selectedCricle.code == data.code ? cell.isSelect() : cell.removeSelection()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCricle = self.arrOfCricle[indexPath.row]
        self.circleTbl.reloadData()
        self.dismiss(animated: false) {
            self.circleSelectEvent?(self.selectedCricle)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        main {
            self.contTblHeight.constant = self.circleTbl.contentSize.height
        }
    }
}
