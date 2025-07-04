
import Foundation
import UIKit

extension UIColor {
    static let themeColor = hexStringToUIColor(hex: "#30a3a0")
    
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

extension CGColor {
    func toHexString() -> String? {
        guard let uiColor = UIColor(cgColor: self) as? UIColor else {
            return nil
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func globalGradientColor() -> UIColor {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    gradientLayer.frame = UIScreen.main.bounds

    UIGraphicsBeginImageContext(gradientLayer.bounds.size)
    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return UIColor(patternImage: image!)
}

