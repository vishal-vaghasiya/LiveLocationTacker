
import Foundation
import UIKit
import MapKit
import AVKit
import StoreKit
import ProgressHUD
import Toast_Swift
import Photos
import CoreHaptics
import SideMenuSwift



let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

var globalNextVC = UIViewController()
var globalAnimated = false



//MARK: - StoryBoard Extension

enum AppStoryboard: String {
    case main
    case tabbar
    
    var description: String {
        switch self {
        case .main:
            return "Main"
        case .tabbar:
            return "TabBar"
        }
    }
}


//MARK: - Log Extension

struct JSN {
    
    static var isNetworkConnected:Bool = false
    static func log(_ logMessage: String,_ args:Any... , functionName: String = #function ,file:String = #file,line:Int = #line) {
        
        let newArgs = args.map({arg -> CVarArg in String(describing: arg)})
        let messageFormat = String(format: logMessage, arguments: newArgs)
        
        print("LOG :- \(((file as NSString).lastPathComponent as NSString).deletingPathExtension)--> \(functionName) ,Line:\(line) :", messageFormat)
    }
    
    static func error(_ logMessage: String,_ args:Any... , functionName: String = #function ,file:String = #file,line:Int = #line) {
        
        let newArgs = args.map({arg -> CVarArg in String(describing: arg)})
        let messageFormat = String(format: logMessage, arguments: newArgs)
        
        print("ERROR :- \(((file as NSString).lastPathComponent as NSString).deletingPathExtension)--> \(functionName) ,Line:\(line) :", messageFormat)
    }
}



//MARK: - UIColor Extension

extension UIColor {
    
    static let fontColor = UIColor(named: "fontcolor") ?? UIColor()
    static let mainColor = UIColor(named: "maincolor") ?? UIColor()
    static let fontGrayColor = UIColor(named: "fontGraycolor") ?? UIColor()
    static let bgColor = UIColor(named: "bgcolor") ?? UIColor()
    static let button_color = UIColor(named: "btncolor") ?? UIColor()
    static let backgroundColor = UIColor(named: "backgroundColor") ?? UIColor()
   
    static var placeholderGray: UIColor {
        return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    }
}



//MARK: - UIFont Extension

public extension UIFont {
    
    func fontWeight(_ weight: UIFont.Weight) -> UIFont {
        let fontDescriptor = UIFontDescriptor(fontAttributes: [
            UIFontDescriptor.AttributeName.size: pointSize,
            UIFontDescriptor.AttributeName.family: familyName
        ])

        // Add the font weight to the descriptor
        let weightedFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: weight
            ]
        ])
        return UIFont(descriptor: weightedFontDescriptor, size: 0)
    }
}


//MARK: - UITextField Extension

extension UITextField {
    
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @available(iOS 13.4, *)
    func datePicker<T>(target: T,
                       doneAction: Selector,
                       cancelAction: Selector,
                       datePickerMode: UIDatePicker.Mode = .date) {
        // Code goes here
        let datePicker = UIDatePicker(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: screenWidth,
                                                    height: 216))
        datePicker.datePickerMode = datePickerMode
        datePicker.preferredDatePickerStyle = .wheels
        self.inputView = datePicker
    }
}


//MARK: - Date Extension

extension Date {
    
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }
    
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }
    
    func getCurrentUTCTimestampInfo() -> (utcString: String, timestampSeconds: Int) {
        let now = self
        
        // Format to UTC string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcString = dateFormatter.string(from: now)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter1.timeZone = .init(secondsFromGMT: 0)
        let utcDate = dateFormatter1.date(from: utcString)
        
        // Timestamps
        let timestampSeconds = Int(utcDate?.timeIntervalSince1970 ?? 0)
        //let timestampMilliseconds = Int(now.timeIntervalSince1970 * 1000)
        
        return (utcString, timestampSeconds)
    }

    
}



// MARK: - UIButton Extension

extension UIButton {
    
//    func setButtonTitleAndFunctionality(_ Name: String,
//                                        cornerRadiues: Double = isIpad() ? 30 : 15,
//                                        titleColor: UIColor = UIColor.black,
//                                        backColor: UIColor = UIColor.mainColor,
//                                        BackgroundImage:UIImage? = UIImage(named: "btn_bg"),
//                                        textFont: UIFont? = AppFont.semiBold(size: isIpad() ? 24 : 18),
//                                        lottieAnimationName: String? = nil, // New parameter for Lottie animation
//                                        isShowLottieWithTitle: Bool = false,
//                                        animationViewWidth:CGFloat = 30,
//                                        animationViewHight:CGFloat = 30 ) {
//        
//        // Set the title
//        self.setTitle(Name, for: .normal)
//        self.titleLabel?.font = textFont
//        self.setTitleColor(titleColor, for: .normal)
//        self.setBackgroundImage(BackgroundImage, for: .normal)
//        self.layer.cornerRadius = CGFloat(cornerRadiues)
//        self.layoutIfNeeded()
//    }
    
    func setButtonTitleAndFunctionality(_ name: String,
                                        cornerRadiues: Double = isIpad() ? 30 : 15,
                                        titleColor: UIColor = .black,
                                        backColor: UIColor = .mainColor,
                                        backgroundImage: UIImage? = UIImage(named: "btn_bg"),
                                        textFont: UIFont? = AppFont.semiBold(size: isIpad() ? 24 : 18),
                                        lottieAnimationName: String? = nil,
                                        isShowLottieWithTitle: Bool = false,
                                        animationViewWidth: CGFloat = 30,
                                        animationViewHight: CGFloat = 30) {
        
        // Create attributed string with image
        let fullString = NSMutableAttributedString()
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: titleColor
        ]
        let title = NSAttributedString(string: "\(name)  ", attributes: titleAttributes)
        fullString.append(title)
        
        let arrowImage = UIImage(named: "icon_arrow_next")
        let attachment = NSTextAttachment()
        attachment.image = arrowImage
        attachment.bounds = CGRect(x: 0, y: (textFont?.descender ?? -4), width: 12, height: 21)
        fullString.append(NSAttributedString(attachment: attachment))
        
        self.setAttributedTitle(fullString, for: .normal)
        self.setBackgroundImage(backgroundImage, for: .normal)
        self.layer.cornerRadius = CGFloat(cornerRadiues)
        self.clipsToBounds = true
        self.layoutIfNeeded()
    }
    
//    func setButtonTitleAndFunctionality(_ name: String,
//                                        cornerRadiues: Double = isIpad() ? 30 : 15,
//                                        titleColor: UIColor = .black,
//                                        backColor: UIColor = .mainColor,
//                                        backgroundImage: UIImage? = UIImage(named: "btn_bg"),
//                                        textFont: UIFont? = AppFont.semiBold(size: isIpad() ? 24 : 18),
//                                        lottieAnimationName: String? = nil,
//                                        isShowLottieWithTitle: Bool = false,
//                                        animationViewWidth: CGFloat = 30,
//                                        animationViewHight: CGFloat = 30,
//                                        isEnabled: Bool = true) { // 👈 Added parameter
//        
//        // 🔧 Button state
//        self.isEnabled = isEnabled
//        self.alpha = isEnabled ? 1.0 : 0.5 // Visual feedback
//        
//        // Create attributed string with image
//        let fullString = NSMutableAttributedString()
//        
//        let titleAttributes: [NSAttributedString.Key: Any] = [
//            .font: textFont ?? UIFont.systemFont(ofSize: 17),
//            .foregroundColor: titleColor
//        ]
//        let title = NSAttributedString(string: "\(name)  ", attributes: titleAttributes)
//        fullString.append(title)
//        
//        if let arrowImage = UIImage(systemName: "chevron.right")?.withTintColor(titleColor, renderingMode: .alwaysOriginal) {
//            let attachment = NSTextAttachment()
//            attachment.image = arrowImage
//            attachment.bounds = CGRect(x: 0, y: (textFont?.descender ?? -4), width: 12, height: 21)
//            fullString.append(NSAttributedString(attachment: attachment))
//        }
//        
//        self.setAttributedTitle(fullString, for: .normal)
//        self.setBackgroundImage(backgroundImage, for: .normal)
//        self.layer.cornerRadius = CGFloat(cornerRadiues)
//        self.clipsToBounds = true
//        self.layoutIfNeeded()
//    }
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.1
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity   = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
    }
    
    
//    func shake() {
//        
//        let shake = CABasicAnimation(keyPath: "position")
//        shake.duration = 0.05
//        shake.repeatCount = 2
//        shake.autoreverses = true
//        
//        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
//        let fromValue = NSValue(cgPoint: fromPoint)
//        
//        let toPoint = CGPoint(x: center.x + 5, y: center.y)
//        let toValue = NSValue(cgPoint: toPoint)
//        
//        shake.fromValue = fromValue
//        shake.toValue = toValue
//        
//        layer.add(shake, forKey: "position")
//    }
}

// MARK: - SKStoreKit Extension

extension SKStoreReviewController {
    
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                if #available(iOS 14.0, *) {
                    requestReview(in: scene)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}


// MARK: - UIImage Extension

extension UIImage {
    
    func drawDottedImage(width: CGFloat, height: CGFloat, color: UIColor) -> UIImage {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 1.0, y: 1.0))
        path.addLine(to: CGPoint(x: width, y: 1))
        path.lineWidth = 1.5
        let dashes: [CGFloat] = [path.lineWidth, path.lineWidth * 5]
        path.setLineDash(dashes, count: 2, phase: 0)
        path.lineCapStyle = .butt
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 2)
        color.setStroke()
        path.stroke()
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func flippedHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: size.width, y: 0.0)
        context.scaleBy(x: -1.0, y: 1.0)

        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return flippedImage
    }

    func flippedVertically() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: 0.0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return flippedImage
    }
}


// MARK: - UIView Extension

extension UIView {

    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-10.0, 10.0, -10.0, 10.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        }else {
            return nil
        }
    }
    
    func makeTopCornerRound(_ cornerRadius:Double = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func makeBottomCornerRound(_ cornerRadius:Double = 20) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func makeTopLeft(_ cornerRadius:Double = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    func makeLeftBottom (_ cornerRadius:Double = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    func makeTopRight(_ cornerRadius:Double = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMaxXMinYCorner]
    }
    func makeRightBottom (_ cornerRadius:Double = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }
    
    func makeLeftBottomAndTopRight(_ cornerRadius:Double = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMinXMaxYCorner , .layerMaxXMinYCorner]
    }
    func makeLeftTopAndRightBottom(_ cornerRadius:Double = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMaxYCorner]
    }
    func makeTopLeftandBottomandLeftBottom(_ cornerRadius:Double = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMinYCorner ,.layerMinXMaxYCorner]
    }
    
    func makeTopLeftandBottomandRightBottom(_ cornerRadius:Double = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMinYCorner ,.layerMaxXMaxYCorner]
    }
    
    func makeRounded() {
        layer.masksToBounds = false
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
        layer.layoutIfNeeded()
    }
    
    func shadow(shadowColor: UIColor, shadowOffset: CGSize, shadowOpacity: Float, shadowRadius: CGFloat) {
        layer.shadowOffset = shadowOffset
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func buttonShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.09).cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 4)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 12.0
        self.layer.masksToBounds = false
    }
    
    func tabShadow(color:CGColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor) {
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func addShadow(_ color:CGColor = UIColor.darkGray.cgColor) {
        layer.shadowOffset = .zero
        layer.shadowColor = color
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func addLightShadow(_ color:CGColor = UIColor.lightGray.cgColor) {
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowColor = color
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 10
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    // Circle Dashed Line.
    func addDashedCircle() {
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        circleLayer.lineWidth = 2.0
        circleLayer.strokeColor =  UIColor.mainColor.cgColor//border of circle
        circleLayer.fillColor = UIColor.clear.cgColor //inside the circle
        circleLayer.lineJoin = .round
        circleLayer.lineDashPattern = [6,3]
        layer.addSublayer(circleLayer)
    }
    
    // Give DashedLine from View.
    func addDashedBorder() {
        let color = UIColor.mainColor.cgColor
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: (frameSize.width - 40)/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        self.layer.addSublayer(shapeLayer)
    }
    
    func parentViewController() -> UIViewController {
        var responder: UIResponder? = self
        while !(responder is UIViewController) {
            responder = responder?.next
            if nil == responder {
                break
            }
        }
        return (responder as? UIViewController)!
    }
    
    func applyGradient(to view: UIView, colors: [String], startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0), cornerRadius: CGFloat = 10.0) {

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { hexStringToUIColor(hex: $0).cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = cornerRadius
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func createDottedLine(width: CGFloat, color: CGColor) {
       let caShapeLayer = CAShapeLayer()
       caShapeLayer.strokeColor = color
       caShapeLayer.lineWidth = width
       caShapeLayer.lineDashPattern = [2,3]
       let cgPath = CGMutablePath()
       let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width - 25, y: 0)]
       cgPath.addLines(between: cgPoint)
       caShapeLayer.path = cgPath
       layer.addSublayer(caShapeLayer)
    }
    
    func takeSnapshotWithoutBackground() -> UIImage? {
        // Save the current background color
        let originalBackgroundColor = self.backgroundColor
        
        // Set the background color to clear
        self.backgroundColor = UIColor.clear
        
        // Create the snapshot image
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            self.backgroundColor = originalBackgroundColor // Restore the original background color
            return nil
        }
        
        layer.render(in: currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        // Restore the original background color
        self.backgroundColor = originalBackgroundColor
        
        return image
    }
    
    func takeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, UIScreen.main.scale)

        guard let currentContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        layer.render(in: currentContext)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        return image
    }
}


// MARK: - UISearchBar Extension

extension UISearchBar {
    
    func setTextFieldColor(_ color: UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                let view = subSubView as? UITextInputTraits
                if view != nil {
                    let textField = view as? UITextField
                    textField?.backgroundColor = color
                    break
                }
            }
        }
    }
    
}


// MARK: - PHAsset Extension

extension PHAsset {
    
    func getAssetThumbnail() -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true // Set to true to use semaphore for synchronous behavior

        var thumbnail: UIImage?
        let semaphore = DispatchSemaphore(value: 0)

        manager.requestImage(for: self,
                             targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight),
                             contentMode: .aspectFit,
                             options: option) { result, _ in
            thumbnail = result
            semaphore.signal() // Signal semaphore to release
        }

        semaphore.wait() // Wait for signal
        return thumbnail
    }
}


// MARK: - String Extension

extension String {
    
    func IsValidphone() -> Bool {
        let phoneRegEx = "[0-9]{10}"
        return applyPredictOnRange(regRgx: phoneRegEx)
    }
    
    func IsvalidPassword()->Bool{
        let passwordRgx = "[A-Z]{1,2}+[a-z]{3,9}+[@&$]{1}+[0-9]{1,4}"
        return applyPredictOnRange(regRgx: passwordRgx)
    }
    
    func applyPredictOnRange(regRgx : String)->Bool {
        let trimmerstring = self.trimmingCharacters(in: .whitespaces)
        let phonetest = NSPredicate(format: "SELF MATCHES %@", regRgx)
        let invalidstring = phonetest.evaluate(with:trimmerstring)
        return invalidstring
    }
    
    func IsValidOtp() -> Bool{
        let phoneRegEx = "[0-9]{10}"
        return applyPredictOnRange(regRgx: phoneRegEx)
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    public func removeFormatAmount() -> Double {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol
        formatter.decimalSeparator = Locale.current.groupingSeparator
        return formatter.number(from: self)?.doubleValue ?? 0.00
    }
    
    func convertToImage() -> UIImage {
        let size = CGSize(width: 100, height: 80)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 70)])
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return image
            
        } else {
            return UIImage()
        }
    }
    
    func insertSlashEveryTwoCharacters() -> String {
        var result = ""
        var index = 0
        for char in self {
            if index > 0 && index % 2 == 0 {
                result += "/"
            }
            result.append(char)
            index += 1
        }
        return result
    }
    
    func insertSpaceAfterFourDigits() -> String {
        var result = ""
        var index = 0
        for char in self {
            if index > 0 && index % 4 == 0 {
                result += " "
            }
            result.append(char)
            index += 1
        }
        return result
    }
    
    func getCharacter(at index: Int) -> String {
        guard index >= 0 && index < count else {
            return ""
        }
        return String(self[self.index(startIndex, offsetBy: index)])
    }
    
    func withoutEmoji() -> String {
        filter { $0.isASCII }
    }
    
    func allowASCII() -> String {
        filter { $0.isASCII }
    }
    
    var removingSpaces: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}


//MARK: - ViewController Extension

extension UIViewController {
   
    func pushVC(_ Name:UIViewController){
        let vc = Name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func instantiate<T: UIViewController>(appStoryboard: AppStoryboard) -> T {
        let storyboard = UIStoryboard(name: appStoryboard.description, bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    
    func pushVC(T: UIViewController, viewControllerID: String, _animated: Bool = false,adsvalue:String = "0") {
        DispatchQueue.main.async {
            guard let nextVC = T.storyboard?.instantiateViewController(withIdentifier: viewControllerID) else { return }
            globalNextVC = nextVC
            globalAnimated = _animated
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
//    func pushVC<T: UIViewController>(T viewController: T, viewControllerID: String) {
//        if let navigationController = self.navigationController {
//            DispatchQueue.main.async {
//                navigationController.pushViewController(viewController, animated: true)
//            }
//        } 
//        else {
//            print("No navigation controller found")
//        }
//    }
    
    func navigateToHome() {
        DispatchQueue.main.async { [self] in
            if Constants.USERDEFAULTS.bool(forKey: "pro") == true {
                Constants.userSubscribeAvailable = true
            }
            else{
                Constants.userSubscribeAvailable = false
            }
            guard let frontViewController = Constants.tab_storyBoard.instantiateViewController(withIdentifier: "HomeTabVC") as? UITabBarController else { return }
            self.view.window?.rootViewController = frontViewController
        }
    }
    
    func navigateToOnboarding() {
        DispatchQueue.main.async {
            let frontViewController = Constants.main_storyBoard.instantiateViewController(identifier: "IntroVC") as! IntroVC
            let frontNavigationController = UINavigationController(rootViewController: frontViewController)
            frontNavigationController.isNavigationBarHidden = true
            self.view.window?.rootViewController = frontNavigationController
        }
    }
    
    var notchHeight:CGFloat {
        let window = UIApplication.shared.windows[0]
        return window.safeAreaInsets.top
    }
    

//    func dropDownConfirgration(anchorview:AnchorView?,width:CGFloat?,datasource:[String],dropDown:DropDown){
//        dropDown.anchorView = anchorview
//        dropDown.width = width
//        dropDown.backgroundColor = .white
//        dropDown.cornerRadius = 10
//        dropDown.bottomOffset = CGPoint(x: 20, y: 35)
//        dropDown.dataSource = datasource
//        dropDown.show()
//    }
    
    func presentImagePickerAlert(completion: @escaping (_ sourceType: UIImagePickerController.SourceType?) -> Void) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Upload or Take Image", message: nil, preferredStyle: .actionSheet)
        
        // Add the actions
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            // Handle Take Photo action
            completion(.camera)
        }
        let chooseFromGalleryAction = UIAlertAction(title: "Choosing From Gallery", style: .default) { _ in
            // Handle Choosing From Gallery action
            completion(.photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Handle Cancel action
            completion(nil)
        }
        
        // Add actions to the alert controller
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromGalleryAction)
        alertController.addAction(cancelAction)
        
        // Check if device is iPad to avoid crash
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        
        DispatchQueue.main.async {
            // Present the alert controller
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func nib() -> Self {
        return UIViewController(nibName: String(describing: Self.self), bundle: Bundle.main) as! Self
    }
    
    func showAlert(title : String, message : String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Add this function in your view controller
    func showAlertForNoInternetConnection() {
        DispatchQueue.main.async { [self] in
            let alertController = UIAlertController(title: "No Internet", message: "Please check you internet connection", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlertPermission(title : String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let settingAction = UIAlertAction(title: "Setting", style: .default, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
               return
            }
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url, options: [:])
                }
            }
        })
        alertController.addAction(okAction)
        alertController.addAction(settingAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func share(message: String, link: String, sourceView: UIView? = nil) {
        if let url = NSURL(string: link) {
            let objectsToShare = [message, url] as [Any]
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                // For iPad, present the activity view controller as a popover
                if let popoverController = activityVC.popoverPresentationController, let sourceView = sourceView {
                    popoverController.sourceView = sourceView
                    popoverController.sourceRect = sourceView.bounds
                    popoverController.permittedArrowDirections = [.up, .down]
                }
                
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    func showFeedback()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var rateCount = Constants.USERDEFAULTS.integer(forKey: "isRate")
            rateCount += 1
            Constants.USERDEFAULTS.set(rateCount, forKey: "isRate")
            if rateCount > 6 {
                SKStoreReviewController.requestReviewInCurrentScene()
                Constants.USERDEFAULTS.removeObject(forKey: "isRate")
            }
        }
    }
    
    func showLoader(text: String){
        DispatchQueue.main.async {
            ProgressHUD.animate(text, interaction: false)
            ProgressHUD.animationType = .circleStrokeSpin
            ProgressHUD.colorAnimation = .maincolor
        }
    }

    func hideLoader(){
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
        }
    }
    
    func showToastMessage(_ message: String) {
        DispatchQueue.main.async {
            var style = ToastStyle()
            style.backgroundColor = .maincolor
            style.messageColor = .white
            ToastManager.shared.style = style
            getTopMostViewController()?.view.makeToast(message,duration: 2.0, position: .top, style: style)
        }
    }
    
    func copyTextToClipboard(_ text: String) {
        // Create a UIPasteboard instance
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
        Constants.ROOTVIEW?.showToastMessage("Copy clipboard")
    }
    
    func saveImageToTemporaryDirectory(imageData: Data) -> URL {
        let tempDir = NSTemporaryDirectory()
        let tempFile = tempDir + UUID().uuidString + ".jpg"
        let tempFileURL = URL(fileURLWithPath: tempFile)
        try? imageData.write(to: tempFileURL)
        return tempFileURL
    }
    
    func checkURLType(inputURL: URL, completion: @escaping (String) -> Void) {
        
        // Most common image types..
        let imageExtensions = ["png", "jpg", "gif", "tif", "JPG", "PNG","HEIC"]
        
        // Most common video types..
        let videoExtensions = ["WEBM", "MPG", "MPEG", "MPE", "MP4", "M4P", "M4V", "AVI", "WMV", "MOV"]
        
        let documentExtensions = ["doc", "docx", "pdf", "txt", "rtf", "odt","xls", "xlsx", "csv","xml", "xhtml"]

        let pathExtension = inputURL.pathExtension
        
        if imageExtensions.contains(pathExtension) {
            print("Image URL: \(inputURL)")
            completion("Image")
        } 
        else if videoExtensions.contains(pathExtension) {
            print("Video URL: \(inputURL)")
            completion("Video")
        }
        else if documentExtensions.contains(pathExtension) {
            print("Document URL: \(inputURL)")
            completion("Document")
        } 
        else {
            print("Does Not Exist: \(inputURL)")
            completion("Unknown")
        }
    }

    func generateThumbnail(for videoURL: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: videoURL)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch {
                print("Error generating thumbnail: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - UIDevice Extension

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()
}



func shakeWithRotation(view: UIView, completion: (() -> Void)?) {
    let rotation = CABasicAnimation(keyPath: "transform.rotation")
    rotation.duration = 0.2
    rotation.repeatCount = 3
    rotation.autoreverses = true
    rotation.fromValue = NSNumber(value: -0.1)
    rotation.toValue = NSNumber(value: 0.1)
    
    CATransaction.begin()
    CATransaction.setCompletionBlock {
        completion?()
    }
    
    view.layer.add(rotation, forKey: "transform.rotation")
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    
    CATransaction.commit()
}

func isIpad() -> Bool {
    if( UIDevice.current.userInterfaceIdiom == .pad) {
        return true
    }
    return false
}

func getCurrencySymbol(from currencyCode: String) -> String? {

    let locale = NSLocale(localeIdentifier: currencyCode)
    if locale.displayName(forKey: .currencySymbol, value: currencyCode) == currencyCode {
        let newlocale = NSLocale(localeIdentifier: currencyCode.dropLast() + "_en")
        return newlocale.displayName(forKey: .currencySymbol, value: currencyCode)
    }
    return locale.displayName(forKey: .currencySymbol, value: currencyCode)
}


//MARK: - getChristmasDate.

func getChristmasDate() -> NSDate {
    let calendar = Calendar.current
    let christmasDateComponents = DateComponents(year: calendar.component(.year, from: Date()), month: 12, day: 25)
    return calendar.date(from: christmasDateComponents)! as NSDate
}

//MARK: - Get App release Version

func getAppInfo()-> Float {
    let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let appVersionInt = Float(appVersionString) ?? 0
    return appVersionInt
}

//MARK: - Emoji Textfield Open.

class EmojiTextField: UITextField {

    // required for iOS 13
    override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}

//MARK: - day change

func hasDayChanged() -> Bool {
    let currentDate = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day, .month, .year], from: currentDate)
    let startOfDay = calendar.date(from: components)!

    var componentsToAdd = DateComponents()
    componentsToAdd.day = 1
    let startOfNextDay = calendar.date(byAdding: componentsToAdd, to: startOfDay)!

    return currentDate >= startOfNextDay
}

//MARK:  - getDate.

func convertStringToDate(_ dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a"
    return dateFormatter.date(from: dateString)!
}

func formatDate(format:String? = "MM-dd-yyyy h:mm:ss a") -> String {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = format
    return timeFormatter.string(from: Date())
}

func timeFormatted(interval: CGFloat, isWithMinutes: Bool) -> String {
    let milliseconds = Int(interval * 1000)
    var seconds = milliseconds / 1000
    let minutes = seconds / 60
    seconds %= 60

    let strMillisec = String(format: "%02d", milliseconds % 1000 / 10)

    if isWithMinutes {
        return String(format: "%02d:%02d.%02d", minutes, seconds, Int(strMillisec) ?? 0)
    } else {
        return String(format: "%02d.%02d", seconds, Int(strMillisec) ?? 0)
    }
}

// Function to separate date and time from a given string
func separateDateAndTime(from dateString: String, inputFormat: String = "MM-dd-yyyy h:mm:ss a") -> (String, String)? {
    // Create a date formatter
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = inputFormat
    
    // Parse the input string into a Date object
    guard let date = dateFormatter.date(from: dateString) else {
        print("Failed to parse the date.")
        return nil
    }
    
    // Create a date formatter for formatting date
    let dateFormatterForDate = DateFormatter()
    dateFormatterForDate.dateFormat = "MM-dd-yyyy"
    
    // Create a date formatter for formatting time
    let dateFormatterForTime = DateFormatter()
    dateFormatterForTime.dateFormat = "h:mm:ss a"
    
    // Format the date and time components separately
    let formattedDate = dateFormatterForDate.string(from: date)
    let formattedTime = dateFormatterForTime.string(from: date)
    
    return (formattedDate, formattedTime)
}

func getTopMostViewController() -> UIViewController? {
    if #available(iOS 13.0, *) {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        var topMostViewController = keyWindow?.rootViewController

        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
    else {
        // Fallback for older iOS versions
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
}
