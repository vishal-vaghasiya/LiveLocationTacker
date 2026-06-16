//
//  ProximityInfoVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 14/08/25.
//

import UIKit

class ProximityInfoVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblLatLong: UILabel!
    @IBOutlet weak var lblRadius: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblAlertTime: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblIDTitle: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblLocationTitle: UILabel!
    @IBOutlet weak var lblCoordinatesTitle: UILabel!
    @IBOutlet weak var lblRadiusTitle: UILabel!
    @IBOutlet weak var lblStatusTitle: UILabel!
    @IBOutlet weak var lblAlertOnTitle: UILabel!
    @IBOutlet weak var lblNoteTitle: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    // MARK: - PROPERTY
    var data = ProximityAlert()
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setNativeAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    // MARK: - UI SETUP
    func setupData() {
        lblID.text = data.id?.short15 ?? "-"
        lblName.text = data.name ?? "No Name"
        lblLocation.text = data.location ?? "No Location"
        lblLatLong.text = "\(data.latitude), \(data.longitude)"
        lblRadius.text = "\(data.radius) m"
        if let dateTime = data.dateTime {
            let now = Date()
            let isActive = (!data.radiusTrigger && dateTime > now)
            lblStatus.text = isActive ? "Active" : "Inactive"
            lblStatus.textColor = isActive ? Asset.appBlack.color : Asset.appRed.color
            btnEdit.isHidden = !isActive
        } else {
            lblStatus.text = "Inactive"
            lblStatus.textColor = Asset.appRed.color
            btnEdit.isHidden = true
        }
        
        if let dateTime = data.dateTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            lblAlertTime.text = formatter.string(from: dateTime)
        } else {
            lblAlertTime.text = "—"
        }
        
        lblNote.text = data.note ?? "No Notes"
        
        setupLocalization()
    }
    
    func setupLocalization() {
        lblTitle.text = L10n.proximityInfo
        lblIDTitle.text = L10n.id
        lblNameTitle.text = L10n.name
        lblLocationTitle.text = L10n.location
        lblCoordinatesTitle.text = L10n.coordinates
        lblRadiusTitle.text = L10n.radius
        lblStatusTitle.text = L10n.status
        lblAlertOnTitle.text = L10n.alertOn
        lblNoteTitle.text = L10n.note
        btnDelete.setTitle(L10n.delete, for: .normal)
    }
    
    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .SMALL) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 120 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backButtonClick(_ sender: UIButton) {
        self.navigateBack()
    }
    
    @IBAction func editButtonClick(_ sender: UIButton) {
        AdManager.shared.showInterstitialAd(from: self) {
            let vc = StoryboardScene.Proximity.addProximityVC.instantiate()
            vc.isEdit = true
            vc.data = self.data
            vc.onEditSuccess = { data in
                self.data = data
                self.setupData()
            }
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func deleteButtonClick(_ sender: UIButton) {
        let vc = StoryboardScene.Circle.commonAlertPopup.instantiate()
        vc.selectedPopType = .Delete_Alert
        vc.clickYesEvent = {
            if let id = self.data.id {
                CoreDataManager.shared.deleteProximityAlert(by: id)
            }
            self.navigateBack()
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
