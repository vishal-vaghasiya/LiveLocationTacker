//
//  Helper+String.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 04/07/25.
//

import Foundation
import UIKit

extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
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
    
    var digitsOnly: String {
        return self.filter { $0.isWholeNumber }
    }
    
    func DegreeToString(d: Double) -> String {
        /// Degree
        let degree = Int(d)
        /// Temporary minute
        let tempMinute = Float(d - Double(degree)) * 60
        /// Minute
        let minutes = Int(tempMinute)   // Round down
        /// Second
        let second = Int((tempMinute - Float(minutes)) * 60)
        return "\(degree)°\(minutes)′\(second)″"
    }
    
    func getBoolValue() -> Bool {
        return self.lowercased().contains("yes")
    }
    
}
