//
//  PopupInviteChildMode.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 02/07/25.
//

import UIKit

class PopupInviteChildMode: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var circleTV: UITableView!
    @IBOutlet weak var conTVHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    var selectedIndex = -1
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        self.circleTV.register(UINib(nibName: "ChildModeCircleTVCell", bundle: nil), forCellReuseIdentifier: "ChildModeCircleTVCell")
        self.circleTV.rowHeight = UITableView.automaticDimension
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func closeButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func inviteClick(_ sender: UIButton) {
        let vc = StoryboardScene.ChildMode.addMemberVC.instantiate()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension PopupInviteChildMode: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChildModeCircleTVCell", for: indexPath) as! ChildModeCircleTVCell
        
        cell.ivArrow.image = self.selectedIndex == indexPath.row ? Asset.iconArrowWhiteUp.image : Asset.iconArrowWhiteDown.image
        cell.buttonView.isHidden = self.selectedIndex != indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedIndex == indexPath.row {
            self.selectedIndex = -1
        } else {
            self.selectedIndex = indexPath.row
        }
        self.circleTV.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            self.conTVHeight.constant = self.circleTV.contentSize.height
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
