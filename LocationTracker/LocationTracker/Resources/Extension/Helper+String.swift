//
//  Helper+String.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import Foundation
import UIKit

extension String {
    
    var localized: String {
        
        // Find the path for the language bundle
        if let path = Bundle.main.path(forResource: DefaultManager.selectedLanguage.langCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        
        // Fallback to base localization
        return NSLocalizedString(self, comment: "")
    }
    
    func allowASCII() -> String {
        filter { $0.isASCII }
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    var length: Int {
        return count
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
    
    var removingSpaces: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    /// Removes leading zero if present
    var withoutLeadingZero: String {
        return self.hasPrefix("0") ? String(self.dropFirst()) : self
    }
    
    /// Removes all non-digit characters and formats a 10-digit number as "NNNNN NNNNN"
    var formattedAsFiveFive: String {
        let digits = self.filter("0123456789".contains)
        guard digits.count == 10 else { return self } // Return original if not 10 digits
        let prefix = digits.prefix(5)
        let suffix = digits.suffix(5)
        return "\(prefix) \(suffix)"
    }
    
    
    /// Formats a phone number like "+919876543210" into "+91 98765 43210"
    func formattedPhoneNumber() -> String {
        // Remove all spaces
        let digitsOnly = self.replacingOccurrences(of: " ", with: "")
        
        // Must start with + and have at least country code + 10 digits
        guard digitsOnly.hasPrefix("+") else { return self }
        
        // Find where country code ends (after + and digits until number starts)
        let indexAfterCountryCode = digitsOnly.index(digitsOnly.startIndex, offsetBy: min(digitsOnly.count, 3))
        
        // Extract country code (everything before first space after +)
        var countryCode = ""
        var remaining = ""
        
        // Read characters until hitting a non-digit after +
        var reachedNumberStart = false
        for char in digitsOnly {
            if char == "+" || (!reachedNumberStart && char.isWholeNumber) {
                if !reachedNumberStart {
                    countryCode.append(char)
                }
            } else {
                reachedNumberStart = true
                remaining.append(char)
            }
        }
        
        // Fallback: if we failed to split, assume first 3 chars are country code
        if remaining.isEmpty {
            countryCode = String(digitsOnly.prefix(3))
            remaining = String(digitsOnly.dropFirst(3))
        }
        
        // Ensure remaining has at least 10 digits for standard formatting
        guard remaining.count >= 10 else { return self }
        
        let firstPart = String(remaining.prefix(5))
        let secondPart = String(remaining.suffix(remaining.count - 5))
        
        return "\(countryCode) \(firstPart) \(secondPart)"
    }
    
    func lineSpacing(noOfLine: Int, alignment:NSTextAlignment = .center) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = CGFloat(noOfLine) // Whatever line spacing you want in points
        paragraphStyle.alignment = alignment//.center
        
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        // *** Set Attributed String to your label ***
        return attributedString
    }
    
    func lineSpacinggWithFont(noOfLine: Int, alignment:NSTextAlignment = .center, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = CGFloat(noOfLine) // Whatever line spacing you want in points
        paragraphStyle.alignment = alignment//.center
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.white, range:NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value:font, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
}
