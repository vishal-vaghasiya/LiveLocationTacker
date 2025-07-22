//
//  MapSettingsVC.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 30/06/25.
//

import UIKit
import MapKit

struct MapTypeOption {
    let mapType: MKMapType
    let imageName: String
    let displayName: String
    let eventName : AnalyticsEventName
}

class MapSettingsVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var mapTypeCV: UICollectionView!
    
    // MARK: - PROPERTY
    var selectedMapType: MKMapType = .standard
    var arrOfMaptypes: [MapTypeOption] = [
        MapTypeOption(mapType: .standard, imageName: "standard_map", displayName: "Standard", eventName: AnalyticsEventName.map_click_standard),
        MapTypeOption(mapType: .satellite, imageName: "satellite_map", displayName: "Satellite", eventName: AnalyticsEventName.map_click_satellite),
        MapTypeOption(mapType: .hybrid, imageName: "hybrid_map", displayName: "Hybrid", eventName: AnalyticsEventName.map_click_hybrid),
    ]
    var updateMap:((MKMapType)->Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        mapTypeCV.register( UINib(nibName: "MapTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "MapTypeCVCell")
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func outerViewAction(_ sender: UIControl) {
        self.dismiss(animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
extension MapSettingsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOfMaptypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapTypeCVCell", for: indexPath as IndexPath) as! MapTypeCVCell
        let data = arrOfMaptypes[indexPath.row]
        cell.data = data
        cell.radioImageView.isHighlighted = selectedMapType == data.mapType
        cell.nameView.backgroundColor = selectedMapType == data.mapType ? Asset.color00BDFF15.color : Asset.colorFFFFFF10.color
        cell.layer.borderColor = selectedMapType == data.mapType ? Asset.color00BDFF.color.cgColor : UIColor.clear.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((mapTypeCV.frame.width - 20)/3)
        return CGSize(width: width, height: mapTypeCV.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = arrOfMaptypes[indexPath.row]
        FirebaseManager.shared.logAnalyticsEvent(name: data.eventName)
        if selectedMapType != data.mapType {
            selectedMapType = data.mapType
            self.mapTypeCV.reloadData()
            self.updateMap?(selectedMapType)
        }
    }
}
