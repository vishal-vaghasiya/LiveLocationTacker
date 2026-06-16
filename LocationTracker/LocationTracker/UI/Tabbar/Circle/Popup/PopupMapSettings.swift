//
//  PopupMapSettings.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit
import MapKit
struct MapTypeOption {
    let mapType: MKMapType
    let imageName: String
    let displayName: String
    let eventName : AnalyticsEventName
}

class PopupMapSettings: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var mapTypeCV: UICollectionView!
    @IBOutlet weak var btnDone: PrimaryButton!
    
    // MARK: - PROPERTY
    var onMapSelectedTapped: ((MKMapType) -> Void)?
    var onMapPreview: ((MKMapType) -> Void)?
    var onMapCancelTapped: (() -> Void)?
    var selectedMapType: MKMapType = .standard
    var arrOfMaptypes: [MapTypeOption] = [
        MapTypeOption(mapType: .standard, imageName: Asset.mapStandard.name, displayName: L10n.standard, eventName: AnalyticsEventName.map_click_standard),
        MapTypeOption(mapType: .satellite, imageName: Asset.mapSatelite.name, displayName: L10n.satellite, eventName: AnalyticsEventName.map_click_satellite),
        MapTypeOption(mapType: .hybrid, imageName: Asset.mapTransit.name, displayName: L10n.transit, eventName: AnalyticsEventName.map_click_hybrid),
    ]
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    func setupLocalization() {
        self.lblTitle.text = L10n.chooseMap
        self.btnDone.setTitle(L10n.done, for: .normal)
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        mapTypeCV.register( UINib(nibName: MapCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: MapCVCell.identifier)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickClose(_ sender: UIButton) {
        self.onMapCancelTapped?()
    }
    
    @IBAction func mapSelectedClick(_ sender: UIButton) {
        self.onMapSelectedTapped?(selectedMapType)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension PopupMapSettings: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOfMaptypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapCVCell.identifier, for: indexPath as IndexPath) as! MapCVCell
        let data = arrOfMaptypes[indexPath.row]
        cell.data = data
        cell.radioImageView.isHighlighted = selectedMapType == data.mapType
        cell.borderWidth = selectedMapType == data.mapType ? 2 : 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((mapTypeCV.frame.width - 30)/3)
        return CGSize(width: width, height: mapTypeCV.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = arrOfMaptypes[indexPath.row]
        FirebaseManager.shared.logAnalyticsEvent(name: data.eventName)
        if selectedMapType != data.mapType {
            selectedMapType = data.mapType
            self.mapTypeCV.reloadData()
            self.onMapPreview?(selectedMapType)
        }
    }
}

