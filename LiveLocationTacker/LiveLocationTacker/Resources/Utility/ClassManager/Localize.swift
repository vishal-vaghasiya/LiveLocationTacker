//
//  Localize.swift
//
//  Created by DREAMWORLD on 19/09/24.
//

import Foundation
import UIKit


struct LanguageClass {
    let langCode: String
    let langName: String
    let langSymName: String
    let langImg: String
}


var arrLanguageList:[LanguageClass] = [
    LanguageClass(langCode: "en", langName: "English", langSymName: "English", langImg: "extended_united_states_dell"),
    LanguageClass(langCode: "de", langName: "German", langSymName: "Deutsch", langImg: "extended_germany_dell"),
    LanguageClass(langCode: "es", langName: "Spanish", langSymName: "Española", langImg: "extended_spain_dell"),
    LanguageClass(langCode: "fr", langName: "French", langSymName: "français", langImg: "extended_france_dell"),
    LanguageClass(langCode: "ha", langName: "Hausa", langSymName: "Hausa", langImg: "extended_nigeria_dell"),
    LanguageClass(langCode: "it", langName: "Italian", langSymName: "Italian", langImg: "extended_italy_dell"),
    LanguageClass(langCode: "ja", langName: "Japanese", langSymName: "日本", langImg: "extended_japan_dell"),
    LanguageClass(langCode: "ms", langName: "Malay", langSymName: "Melayu", langImg: "extended_malaysia_dell"),
    LanguageClass(langCode: "nl", langName: "Dutch", langSymName: "Nederland", langImg: "extended_netherlands_dell"),
    LanguageClass(langCode: "pl", langName: "Polish", langSymName: "Polanski", langImg: "extended_poland_dell"),
    LanguageClass(langCode: "hi", langName: "Hindi", langSymName: "हिंदी", langImg: "extended_india_dell"),
    LanguageClass(langCode: "pt", langName: "Portuguese", langSymName: "Portuguese", langImg: "extended_portugal_dell"),
    LanguageClass(langCode: "ro", langName: "Romanian", langSymName: "Română", langImg: "extended_romania_dell"),
    LanguageClass(langCode: "sv", langName: "Swedish", langSymName: "svenska", langImg: "extended_sweden_dell"),
    LanguageClass(langCode: "th", langName: "Thai", langSymName: "ไทย", langImg: "extended_thailand_dell"),
    LanguageClass(langCode: "tr", langName: "Turkish", langSymName: "Türk", langImg: "extended_turkey_dell"),
    LanguageClass(langCode: "vi", langName: "Vietnamese", langSymName: "Tiếng Việt", langImg: "extended_vietnam_dell"),
    LanguageClass(langCode: "bg", langName: "Bulgarian", langSymName: "български", langImg: "extended_bulgaria_dell"),
    LanguageClass(langCode: "da", langName: "Danish", langSymName: "dansk", langImg: "extended_denmark_dell"),
    LanguageClass(langCode: "fil", langName:"Filipino", langSymName: "Filipino", langImg: "extended_philippines_dell"),
    LanguageClass(langCode: "ru", langName: "Russian", langSymName: "русский", langImg: "extended_russia_dell"),
    LanguageClass(langCode: "id", langName: "Indonesian", langSymName: "bahasa Indonesia", langImg: "extended_indonesia_dell"),
    LanguageClass(langCode: "el", langName: "Greek", langSymName: "Ελληνικά", langImg: "extended_greece_dell"),
    LanguageClass(langCode: "lv", langName: "Latvian", langSymName: "latviski", langImg: "extended_latvia_dell"),
    LanguageClass(langCode: "so", langName: "Somali", langSymName: "somaliyeed", langImg: "extended_kenya_dell"),
    LanguageClass(langCode: "af", langName: "Afrikaans", langSymName: "Afrikaans", langImg: "extended_africa_dell"),
    LanguageClass(langCode: "ar", langName: "Arabic", langSymName: "عربي", langImg: "extended_arabic_dell"),
    LanguageClass(langCode: "la", langName: "Latin", langSymName: "Latinus", langImg: "extended_italy_dell"),
    LanguageClass(langCode: "ta", langName: "Tamil", langSymName: "தமிழ்", langImg: "extended_india_dell"),
    LanguageClass(langCode: "te", langName: "Telugu", langSymName: "தெலுங்கு", langImg: "extended_india_dell")
]


//MARK: - get SetAppLanguageCode. -

func getAppLanguagesCode() -> String?{
    return  UserDefaults.standard.string(forKey: "Applanguage")
}


//MARK: - Localize The DataUseful.
extension Bundle {
    
    private static var bundle: Bundle!
    public static func localizedBundle() -> Bundle{
        let lang = UserDefaults.standard.string(forKey: "Applanguage")
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        bundle = Bundle(path: path!)
        return bundle!
    }
    
    public static func setLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "Applanguage")
        UserDefaults.standard.synchronize()
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        bundle = Bundle(path: path!)
        let defaults = UserDefaults()
        defaults.isArabic()
        
    }
}

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable" , bundle: Bundle.localizedBundle(), value: "", comment: "")
    }
    
    func localizeWithFormat(arguments: CVarArg...) -> String{
        return String(format: self.localized(), arguments: arguments)
    }
}


//MARK: - ChangeUIView Direction when LanguageUpdate -

extension UserDefaults{
    
    func isArabic(){
        if UserDefaults.standard.string(forKey: "Applanguage") == "ar"{
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            UIButton.appearance().semanticContentAttribute = .forceRightToLeft
        }
        else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            UIButton.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
    
}

//MARK: - When Language update ChnageUI ATTime -

extension UIViewController{
    
    func changeUIRuntime() {
        let currentNavigation = self.navigationController
        let newNavigation =  UINavigationController()
        newNavigation.viewControllers = currentNavigation?.viewControllers ?? []
        newNavigation.setNavigationBarHidden(true, animated: false)
        self.view.window?.rootViewController = newNavigation
        
        //        let navCtrl = self.storyboard?.instantiateViewController(withIdentifier: "rootnav")
        //        let keyWindow = UIApplication.shared.connectedScenes
        //            .filter({$0.activationState == .foregroundActive})
        //                .compactMap({$0 as? UIWindowScene})
        //                .first?.windows
        //                .filter({$0.isKeyWindow}).first
        //        guard
        //            let window = keyWindow,
        //            let rootViewController = window.rootViewController
        //
        //        else {
        //            return
        //        }
        //        navCtrl?.view.frame = rootViewController.view.frame
        //        navCtrl?.view.layoutIfNeeded()
        //
        //        UIView.transition(with: window, duration: 0.2, options: .transitionFlipFromRight, animations: {
        //            window.rootViewController = navCtrl
        //            window.makeKeyAndVisible()
        ////        })
    }
}

//MARK: - Change ImageView Direction when Language Update.

extension UIImageView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        if UserDefaults.standard.string(forKey: "Applanguage") == "ar" {
            // Set semantic attribute for RTL layout
            self.semanticContentAttribute = .forceRightToLeft
        } else {
            // Set semantic attribute for LTR layout
            self.semanticContentAttribute = .forceLeftToRight
        }
    }
}

//MARK: - ChanegTexfield Direction when LanguageUpdate.

extension UITextField {
    open override func awakeFromNib() {
        super.awakeFromNib()
        if UserDefaults.standard.string(forKey: "Applanguage") == "ar" {
            if textAlignment == .natural {
                self.textAlignment = .right
            }
        }
    }
}

//MARK: - ChanegTextView Direction when LanguageUpdate.

extension UITextView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        if UserDefaults.standard.string(forKey: "Applanguage") == "ar" {
            if textAlignment == .natural {
                self.textAlignment = .right
            }
        }
    }
}

//MARK: - ChangeButton Direction when LanguageUpdate.

extension UIButton {
    open override func awakeFromNib() {
        super.awakeFromNib()
        if UserDefaults.standard.string(forKey: "Applanguage") == "ar" {
            self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
    }
}
