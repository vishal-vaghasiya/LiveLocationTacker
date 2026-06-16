//
//  Untitled.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit

private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.prefix(maxLength).string
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
         get {
             return self.placeHolderColor
         }
         set {
             self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
         }
     }
}

extension LosslessStringConvertible {
    var string: String { return String(self) }
}

enum ValidationType {
    case DEFAULT
}
public class MaskTextField: UITextField {
    
    var filterFunction: ((String) -> String)?
    var validationType: ValidationType = .DEFAULT {
        didSet {
            setupValidation()
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        applyFilter(textField: textField)
    }
    
    public func applyFilter(textField: UITextField) {
        if _mask == nil || _mask.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            return
        }
        var index = _mask.startIndex
        var textWithMask: String = ""
        var i: Int = 0
        var text: String = textField.text!
        if (text.isEmpty) {
            return
        }
        text = removeMaskCharacters(text: text, withMask: maskString)
        while(index != maskString.endIndex) {
            if(i >= text.count) {
                self.text = textWithMask
                break
            }
            if("\(maskString[index])" == "N") { // Only number
                if (!isNumber(textToValidate: text[i])) {
                    break
                }
                textWithMask = textWithMask + text[i]
                i += 1
            } else if("\(maskString[index])" == "C") { // Only Characters A-Z, Upper case only
                if(hasSpecialCharacter(searchTerm: text[i])) {
                    break
                }
                
                if (isNumber(textToValidate: text[i])) {
                    break
                }
                textWithMask = textWithMask + String(text[i]).uppercased()
                i += 1
            } else if("\(maskString[index])" == "c") { // Only Characters a-z, lower case only
                if(hasSpecialCharacter(searchTerm: text[i])) {
                    break
                }
                
                if (isNumber(textToValidate: text[i])) {
                    break
                }
                textWithMask = textWithMask + String(text[i]).lowercased()
                i += 1
            } else if("\(maskString[index])" == "X") { // Only Characters a-Z
                if(hasSpecialCharacter(searchTerm: text[i])) {
                    break
                }
                
                if (isNumber(textToValidate: text[i])) {
                    break
                }
                textWithMask = textWithMask + text[i]
                i += 1
            } else if("\(maskString[index])" == "%") { // Characters a-Z + Numbers
                if(hasSpecialCharacter(searchTerm: text[i])) {
                    break
                }
                textWithMask = textWithMask + text[i]
                i += 1
            } else if("\(maskString[index])" == "U") { // Only Characters A-Z + Numbers, Upper case only
                if(hasSpecialCharacter(searchTerm: text[i])) {
                    break
                }
                textWithMask = textWithMask + String(text[i]).uppercased()
                i += 1
            } else if("\(maskString[index])" == "u") { // Only Characters a-z + Numbers, lower case only
                if(hasSpecialCharacter(searchTerm: text[i])) {
                    break
                }
                textWithMask = textWithMask + String(text[i]).lowercased()
                i += 1
            } else if("\(maskString[index])" == "*") { // Any Character
                textWithMask = textWithMask + text[i]
                i += 1
            } else {
                textWithMask = textWithMask + "\(maskString[index])"
            }
            index = _mask.index(after: index)
        }
        self.text = textWithMask
    }
    
    public func removeMaskCharacters(text: String, withMask mask: String) -> String {
        var mask = mask
        var text = text
        mask = mask.replacingOccurrences(of: "X", with: "")
        mask = mask.replacingOccurrences(of: "N", with: "")
        mask = mask.replacingOccurrences(of: "C", with: "")
        mask = mask.replacingOccurrences(of: "c", with: "")
        mask = mask.replacingOccurrences(of: "U", with: "")
        mask = mask.replacingOccurrences(of: "u", with: "")
        mask = mask.replacingOccurrences(of: "*", with: "")
        
        var index = mask.startIndex
        
        while(index != mask.endIndex) {
            text = text.replacingOccurrences(of: "\(mask[index])", with: "")
            index = mask.index(after: index)
        }
        
        return text
    }
    
    public func hasSpecialCharacter(searchTerm: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
        if regex.firstMatch(in: searchTerm, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, searchTerm.count)) != nil {
            return true
        }
        return false
    }
    
    public func isNumber(textToValidate: String) -> Bool {
        let num = Int(textToValidate)
        if num != nil {
            return true
        }
        return false
    }
    
    private var _mask: String!
    @IBInspectable public var maskString: String {
        get {
            return _mask
        }
        set {
            _mask = newValue
        }
    }
}

extension MaskTextField {
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupValidation()
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, let filterFunction = filterFunction else { return }
        let filteredText = filterFunction(text)
        // Enforce the maxLength based on validationType
        textField.text = filteredText
    }
    
    private func setupValidation() {
        switch validationType {
        case .DEFAULT:
            filterFunction = { text in
                let resultText = text.allowASCII()
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        }
    }
}
