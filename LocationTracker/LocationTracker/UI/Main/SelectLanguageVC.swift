//
//  SelectLanguageVC.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 02/09/25.
//

import UIKit

class SelectLanguageVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblLanguage: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var contNativeAdHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    let arrOfLang: [LanguageType] = [
        .English, .Spanish, .German, .French, .Hausa, .Italian,
        .Japanese, .Malay, .Dutch, .Polish, .Hindi, .Portuguese, .Romanian,
        .Swedish, .Thai, .Turkish, .Vietnamese, .Bulgarian, .Danish,
        .Filipino, .Russian, .Indonesian, .Greek, .Latvian, .Somali,
        .Afrikaans, .Latin
    ]
    var selectedLung: LanguageType = DefaultManager.selectedLanguage
    var changeLungEvent: (() -> ())?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLocalization()
    }
    
    // MARK: - UI SETUP
    func setUp() {
        self.btnBack.isHidden = !DefaultManager.IS_INITIAL_SETUP
        self.lblTitle.text = DefaultManager.IS_INITIAL_SETUP ? "Change Language" : "Select Language"
        self.tblLanguage.register(UINib(nibName: LanguageCell.identifier, bundle: nil), forCellReuseIdentifier: LanguageCell.identifier)
        self.tblLanguage.delegate = self
        self.tblLanguage.dataSource = self
        self.tblLanguage.showsVerticalScrollIndicator = false
        self.tblLanguage.showsHorizontalScrollIndicator = false
        self.tblLanguage.reloadData()
        self.setNativeAd()
    }
    
    func setupLocalization() {
        self.lblTitle.text = L10n.selectLanguage
    }

    func setNativeAd() {
        AdManager.shared.loadNativeAd(in: self.nativeAdContainer, adType: .LARGE) { isShow in
            self.nativeAdContainer.isHidden = !isShow
            self.contNativeAdHeight.constant = isShow ? 270 : 0
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    @IBAction func clickDone(_ sender: UIButton) {
        DefaultManager.selectedLanguage = self.selectedLung
        AdManager.shared.showInterstitialAd(from: self) {
            if DefaultManager.IS_INITIAL_SETUP {
                self.navigateBack()
                self.changeLungEvent?()
            } else {
                let vc = StoryboardScene.Main.onboardingVC.instantiate()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}

//MARK: - TABLEVIEW
extension SelectLanguageVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfLang.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageCell.identifier, for: indexPath) as! LanguageCell
        let data = self.arrOfLang[indexPath.row]
        cell.languageData = data
        self.selectedLung == data ? cell.isSelect() : cell.removeSelection()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedLung == .NONE {
            setNativeAd()
        }
        self.selectedLung = self.arrOfLang[indexPath.row]
        self.tblLanguage.reloadData()
    }
    
    
}
