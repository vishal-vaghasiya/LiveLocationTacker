//
//  AddProximityVC.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 13/08/25.
//

struct AddressType {
    let id: Int
    let name: String
    let icon: String
}

let addressTypes = [
    AddressType(id: 1, name: L10n.home, icon: Asset.proxiTypeHome.name),
    AddressType(id: 2, name: L10n.gym, icon: Asset.proxiTypeGym.name),
    AddressType(id: 3, name: L10n.office,  icon: Asset.proxiTypeOffice.name),
    AddressType(id: 4, name: L10n.shop, icon: Asset.proxiTypeShop.name),
    AddressType(id: 5, name: L10n.education, icon: Asset.proxiTypeEducation.name),
    AddressType(id: 6, name: L10n.hospital, icon: Asset.proxiTypeHospital.name),
    AddressType(id: 0, name: L10n.other, icon: Asset.proxiTypeOther.name)
]

import UIKit
import CoreLocation
class AddProximityVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var ivSearch: UIImageView!
    @IBOutlet weak var btnOpenMap: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var addressTypeCV: UICollectionView!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var lblRadius: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var pushNotificationSwitch: UISwitch!
    @IBOutlet weak var noteTextview: PlaceholderTextView!
    @IBOutlet weak var addAlertButton: PrimaryButton!
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNameTItle: UILabel!
    @IBOutlet weak var lblLocationTitle: UILabel!
    @IBOutlet weak var lblSelectLocationPlaceholderTitle: UITextField!
    @IBOutlet weak var btnOpenMapTitle: UIButton!
    @IBOutlet weak var lblTypeTitle: UILabel!
    @IBOutlet weak var lblAlertDataTimeTitle: UILabel!
    @IBOutlet weak var lblSelectDateTitle: UITextField!
    @IBOutlet weak var lblSelectTimeTitle: UITextField!
    @IBOutlet weak var lblRadiusTitle: UILabel!
    @IBOutlet weak var lblPushNotificationTitle: UILabel!
    @IBOutlet weak var lblNoteTitle: UILabel!
    
    // MARK: - PROPERTY
    var selectedLocation: CLLocationCoordinate2D?
    var selectedDate: Date?
    var selectedTime: Date?
    var isEdit: Bool = false
    var data = ProximityAlert()
    var selectedType: Int = -1
    var onEditSuccess: ((ProximityAlert) -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if isEdit {
            self.setupData()
        } else {
            self.setupLocationUI()
        }
        setupButton()
        setNativeAd()
        // ✅ Set custom thumb image
        radiusSlider.setThumbImage(Asset.sliderThumb.image, for: .normal)
        radiusSlider.setThumbImage(Asset.sliderThumb.image, for: .highlighted)
        
        addressTypeCV.register( UINib(nibName: AddressTypeCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: AddressTypeCVCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setupLocalization(){
        noteTextview.placeholder = L10n.enterNoteAboutThisAlert
        
        lblTitle.text = L10n.proximityAlert
        lblNameTItle.text = L10n.name
        lblLocationTitle.text = L10n.location
        lblSelectLocationPlaceholderTitle.placeholder = L10n.selectLocation
        btnOpenMapTitle.setTitle(L10n.openMap, for: .normal)
        lblTypeTitle.text = L10n.type
        lblAlertDataTimeTitle.text = L10n.alertDateAndTime
        lblSelectDateTitle.placeholder = L10n.selectDate
        lblSelectTimeTitle.placeholder = L10n.selectTime
        lblRadiusTitle.text = L10n.radius
        lblPushNotificationTitle.text = L10n.pushNotification
        lblNoteTitle.text = L10n.note
        
        txtName.placeholder = L10n.enterName
        txtDate.placeholder = L10n.selectDate
        txtTime.placeholder = L10n.selectTime
        
        addAlertButton.setTitle(isEdit ? L10n.saveAlert : L10n.addAlert, for: .normal)
    }
    
    func setupData(){
        self.txtName.text = self.data.name
        if let location = self.data.location {
            self.txtLocation.text = location
        }
        self.selectedDate = self.data.dateTime
        if let date = self.data.dateTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            self.txtDate.text = formatter.string(from: date)
            formatter.dateFormat = "hh:mm a"
            self.txtTime.text = formatter.string(from: date)
        }
        self.selectedLocation = CLLocationCoordinate2D(latitude: self.data.latitude, longitude: self.data.longitude)
        self.selectedType = Int(data.type)
        self.lblRadius.text = "\(self.data.radius)m"
        self.radiusSlider.value = Float(self.data.radius)
        self.pushNotificationSwitch.isOn = self.data.pushNotification
        self.noteTextview.text = self.data.note
        self.setupLocationUI()
    }
    
    func setupLocationUI(){
        ivSearch.isHidden = self.txtLocation.text?.count ?? 0 > 0
        btnOpenMap.isHidden = self.txtLocation.text?.count ?? 0 > 0
        btnClear.isHidden = !(self.txtLocation.text?.count ?? 0 > 0)
    }
    
    func setupButton() {
        let name = txtName.text ?? ""
        let address = txtLocation.text ?? ""
        let dateString = txtDate.text ?? ""
        let timeString = txtTime.text ?? ""
        let selectedType = selectedType
        
        let isEnabled = name.isEmpty == false && address.isEmpty == false && dateString.isEmpty == false && timeString.isEmpty == false && selectedType != -1
        addAlertButton.isEnabled = isEnabled
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
        if !isEdit {
            let name = txtName.text ?? ""
            let address = txtLocation.text ?? ""
            let dateString = txtDate.text ?? ""
            let timeString = txtTime.text ?? ""
            let selectedType = selectedType
            
            if name.isEmpty == false || address.isEmpty == false || dateString.isEmpty == false || timeString.isEmpty == false || selectedType != -1 {
                let vc = StoryboardScene.Circle.commonAlertPopup.instantiate()
                vc.selectedPopType = .Leave_without_alert
                vc.clickYesEvent = {
                    self.navigateBack()
                }
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false)
            } else {
                self.navigateBack()
            }
        } else {
            self.navigateBack()
        }
    }
    
    /*@IBAction func selectLocationClick(_ sender: UIButton) {
        let vc = StoryboardScene.Proximity.placeSearchVC.instantiate()
        vc.delegate = self
        present(vc, animated: true)
    }*/
    
    @IBAction func selectDateClick(_ sender: UIButton) {
        let alert = UIAlertController(title: L10n.selectDate, message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels // iOS style
        datePicker.frame = CGRect(x: 0, y: 20, width: alert.view.bounds.size.width - 20, height: 200)
        
        // Optional: set minimum date to current time
        datePicker.minimumDate = Date()
        
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: L10n.done, style: .default, handler: { _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            self.txtDate.text = formatter.string(from: datePicker.date)
            self.selectedDate = datePicker.date
            self.setupButton()
        }))
        present(alert, animated: true)
    }
    
    @IBAction func selectTimeClick(_ sender: UIButton) {
        let alert = UIAlertController(title: L10n.selectTime, message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels // iOS style
        datePicker.frame = CGRect(x: 0, y: 20, width: alert.view.bounds.size.width - 20, height: 200)
        
        // Optional: set minimum date to current time
        datePicker.minimumDate = Date()
        
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: L10n.done, style: .default, handler: { _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            self.txtTime.text = formatter.string(from: datePicker.date)
            self.selectedTime = datePicker.date
            self.setupButton()
        }))
        present(alert, animated: true)
    }
    
    @IBAction func radiusValueChanged(_ sender: UISlider) {
        self.lblRadius.text = Int(sender.value.rounded()).description + "m"
        self.setupButton()
    }
    
    @IBAction func openMapButtonClick(_ sender: UIButton) {
        let vc = StoryboardScene.Proximity.openMapVC.instantiate()
        vc.selectedCoordinate = self.selectedLocation
        vc.address = self.txtLocation.text ?? ""
        vc.onSaveContinueTapped = { coordinate, address in
            self.txtLocation.text = address
            self.selectedLocation = coordinate
            self.setupButton()
            self.setupLocationUI()
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func clearButtonClick(_ sender: UIButton) {
        self.txtLocation.text = ""
        self.setupLocationUI()
        self.setupButton()
    }
    
    @IBAction func addAlertButtonClick(_ sender: PrimaryButton) {
        guard let name = self.txtName.text,
              let location = self.txtLocation.text,
              let coordinate = self.selectedLocation,
              let selectedDate = selectedDate,
              let selectedTime = selectedTime else {
            print("⚠️ Missing data")
            return
        }
        
        var finalDate = Date()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedTime)
        
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = timeComponents.second
        
        if let mergedDate = calendar.date(from: mergedComponents) {
            finalDate = mergedDate
        }
        print("finalDate::\(finalDate)")
        
        let radiusValue = Double(self.lblRadius.text?.replacingOccurrences(of: "m", with: "") ?? "0") ?? 0
        Loader.show("")
        if isEdit {
            CoreDataManager.shared.updateProximityAlert(
                by: data.id ?? UUID(),
                name: name,
                location: location,
                type: Int64(self.selectedType),
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                radius: radiusValue,
                dateTime: finalDate,
                pushNotification: self.pushNotificationSwitch.isOn,
                note: self.noteTextview.text ?? ""
            ) { success, message in
                Loader.hide()
                showToast(message: message)
                if success {
                    print("✅ Alert saved successfully!")
                    self.data.name = name
                    self.data.location = location
                    self.data.type = Int64(self.selectedType)
                    self.data.latitude = coordinate.latitude
                    self.data.longitude = coordinate.longitude
                    self.data.radius = radiusValue
                    self.data.dateTime = finalDate
                    self.data.pushNotification = self.pushNotificationSwitch.isOn
                    self.data.note = self.noteTextview.text ?? ""
                    
                    self.onEditSuccess?(self.data)
                    self.navigateBack()
                } else {
                    print("❌ Failed to save alert.")
                }
            }
        } else {
            CoreDataManager.shared.saveProximityAlert(
                name: name,
                location: location,
                type: Int64(self.selectedType),
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                radius: radiusValue,
                dateTime: finalDate,
                pushNotification: self.pushNotificationSwitch.isOn,
                note: self.noteTextview.text ?? ""
            ) { success, message in
                Loader.hide()
                showToast(message: message)
                if success {
                    let vc = StoryboardScene.Circle.commonAlertPopup.instantiate()
                    vc.selectedPopType = .Alert_Saved
                    vc.clickYesEvent = {
                        self.navigateBack()
                    }
                    vc.modalPresentationStyle = .overCurrentContext
                    self.present(vc, animated: false)
                } else {
                    print("❌ Failed to save alert.")
                }
            }
        }
    }
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}

extension AddProximityVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addressTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddressTypeCVCell.identifier, for: indexPath as IndexPath) as! AddressTypeCVCell
        let data = addressTypes[indexPath.row]
        cell.data = data
        cell.borderColor = selectedType == data.id ? Asset.appMain.color : Asset.appLightGrey.color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: addressTypeCV.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = addressTypes[indexPath.row]
        if selectedType == data.id { return }
        selectedType = data.id
        addressTypeCV.reloadData()
        setupButton()
    }
}

