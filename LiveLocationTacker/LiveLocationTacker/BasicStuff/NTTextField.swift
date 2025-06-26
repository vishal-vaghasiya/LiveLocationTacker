//
//  NTTextField.swift
//  CareCoordinations
//
//  Created by Nexios02 on 27/09/24.
//  Copyright © 2024 VISHAL VAGHASIYA. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

enum ValidationType {
    case DEFAULT
    
    case INVITATION_CODE
    
    //NAME
    case FIRST_NAME
    case MIDDLE_NAME
    case LAST_NAME
    case TITLE
    
    case NPI
    case SEARCH//CHECKING
    case MRN
    case EMR
    
    case EMAIL
    case MOBILE_NUMBER
    case FAX
    
    //PASSWORD
    case PASSWORD//CHECKING
    case CONFIRM_PASSWORD//CHECKING
    case PASSWORD_PASTE//CHECKING
    case CONFIRM_PASSWORD_PASTE//CHECKING
    
    //CHANNEL
    case GROUP_NAME
    case BROADCAST_NAME
    case MINI_GROUP_NAME
    
    //ADDRESS
    case STREET_NUMBER_NAME
    case CITY
    case APPARTMENT
    case SUIT
    case ZIPCODE
}

public extension String {
    var isEmptyStr:Bool{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty
    }
}

public class NTTextField: UITextField {
    //MARK: - Validation setup for numbers value also not allow
    var filterFunction: ((String) -> String)?
    var validationType: ValidationType = .DEFAULT {
        didSet {
            setupValidation()
        }
    }
    
    public enum FloatingDisplayStatus{
        case always
        case never
        case defaults
    }
    
    public enum NTBorderStyle{
        case none
        case rounded
        case sqare
        case top
        case bottom
        case left
        case right
    }
    
    fileprivate var lblFloatPlaceholder:UILabel             = UILabel()
    fileprivate var lblError:UILabel                        = UILabel()
    
    fileprivate let paddingX:CGFloat                        = 5.0
    
    fileprivate let paddingHeight:CGFloat                   = 10.0
    fileprivate var borderLayer:CALayer                     = CALayer()
    public var dtLayer:CALayer                              = CALayer()
    public var floatPlaceholderColor:UIColor                = UIColor.black.withAlphaComponent(0.65)
    public var floatPlaceholderActiveColor:UIColor          = UIColor.black.withAlphaComponent(0.65)
    public var floatingLabelShowAnimationDuration           = 0.3
    public var floatingDisplayStatus:FloatingDisplayStatus  = .defaults
    public var borderWidths:CGFloat                          = 0.0{
        didSet{
            let borderStyle = ntborderStyle;
            ntborderStyle = borderStyle
        }
    }

    // maxLength property to store maximum length per validation type
    private var characterLimit: Int = Int.max
    
    public var ntborderStyle:NTBorderStyle = .none{
        didSet{
            borderLayer.removeFromSuperlayer()
            switch ntborderStyle {
            case .none:
                dtLayer.cornerRadius        = 0.0
                dtLayer.borderWidth         = 0.0
            case .rounded:
                dtLayer.cornerRadius        = 4.5
                dtLayer.borderWidth         = borderWidths
                dtLayer.borderColor         = borderColors.cgColor
            case .sqare:
                dtLayer.cornerRadius        = 0.0
                dtLayer.borderWidth         = borderWidths
                dtLayer.borderColor         = borderColors.cgColor
            case .bottom,.left,.right,.top:
                dtLayer.cornerRadius        = 0.0
                dtLayer.borderWidth         = 0.0
                borderLayer.backgroundColor = borderColors.cgColor
                if ntborderStyle == .bottom {
                    borderLayer.frame = CGRect(x: 0, y: dtLayer.bounds.size.height - borderWidths, width: dtLayer.bounds.size.width, height: borderWidths)
                }else if ntborderStyle == .left{
                    borderLayer.frame = CGRect(x: 0, y: 0, width: borderWidths, height: dtLayer.bounds.size.height)
                }else if ntborderStyle == .right{
                    borderLayer.frame = CGRect(x: dtLayer.bounds.size.width - borderWidths, y: 0, width: borderWidths, height: dtLayer.bounds.size.height)
                }else{
                    borderLayer.frame = CGRect(x: 0, y: 0, width: dtLayer.bounds.size.width, height: borderWidths)
                }
                dtLayer.addSublayer(borderLayer)
            }
        }
    }
    
    public var errorMessage:String = ""{
        didSet{ lblError.text = errorMessage }
    }
    
    public var animateFloatPlaceholder:Bool = true
    public var hideErrorWhenEditing:Bool   = true
    
    public var errorFont = UIFont.systemFont(ofSize: 10.0){
        didSet{
            lblError.font = errorFont
            invalidateIntrinsicContentSize()
        }
    }
    
    public var errorTextColor = UIColor.red {
        didSet{
            lblError.textColor = errorTextColor
        }
    }
    
    public var floatPlaceholderFont = IS_IPHONE ?  UIFont.systemFont(ofSize: 12.0) : UIFont.systemFont(ofSize: 17.0){
        didSet{
            lblFloatPlaceholder.font = floatPlaceholderFont
            invalidateIntrinsicContentSize()
        }
    }
    
    public var paddingYFloatLabel:CGFloat = 3.0{
        didSet{ invalidateIntrinsicContentSize() }
    }
    
    public var paddingYErrorLabel:CGFloat = 3.0{
        didSet{ invalidateIntrinsicContentSize() }
    }
    
    public var borderColors:UIColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0){
        didSet{
            switch ntborderStyle {
            case .none,.rounded,.sqare:
                dtLayer.borderColor = borderColors.cgColor
            case .bottom,.right,.top,.left:
                borderLayer.backgroundColor = borderColors.cgColor
            }
        }
    }
    
    public var canShowBorder:Bool = true{
        didSet{
            switch ntborderStyle {
            case .none,.rounded,.sqare:
                dtLayer.isHidden = !canShowBorder
            case .bottom,.right,.top,.left:
                borderLayer.isHidden = !canShowBorder
            }
        }
    }
    
    public var placeholderColor:UIColor?{
        didSet{
            guard let color = placeholderColor else { return }
            attributedPlaceholder = NSAttributedString(string: placeholderFinal,
                                                       attributes: [NSAttributedString.Key.foregroundColor:color])
        }
    }
    
    fileprivate var x:CGFloat {
        if let leftView = leftView {
            return leftView.frame.origin.x + leftView.bounds.size.width - paddingX
        }
        return paddingX
    }
    
    fileprivate var fontHeight:CGFloat{
        return ceil(font!.lineHeight)
    }
    
    fileprivate var dtLayerHeight:CGFloat{
        return showErrorLabel ? floor(bounds.height - lblError.bounds.size.height - paddingYErrorLabel) : bounds.height
    }
    
    fileprivate var floatLabelWidth:CGFloat{
        var width = bounds.size.width
        if let leftViewWidth = leftView?.bounds.size.width{
            width -= leftViewWidth
        }
        if let rightViewWidth = rightView?.bounds.size.width {
            width -= rightViewWidth
        }
        return width - (self.x * 2)
    }
    
    fileprivate var placeholderFinal:String{
        if let attributed = attributedPlaceholder { return attributed.string }
        return placeholder ?? " "
    }
    
    fileprivate var isFloatLabelShowing:Bool = false
    
    fileprivate var showErrorLabel:Bool = false{
        didSet{
            guard showErrorLabel != oldValue else { return }
            guard showErrorLabel else {
                hideErrorMessage()
                return
            }
            guard !errorMessage.isEmptyStr else { return }
            showErrorMessage()
        }
    }
    
    override public var borderStyle: UITextField.BorderStyle{
        didSet{
            guard borderStyle != oldValue else { return }
            borderStyle = .none
        }
    }
    
    public override var textAlignment: NSTextAlignment{
        didSet{ setNeedsLayout() }
    }
    
    public override var text: String?{
        didSet{ self.textFieldTextChanged() }
    }
    
    override public var placeholder: String?{
        didSet{
            guard let color = placeholderColor else {
                lblFloatPlaceholder.text = placeholderFinal
                return
            }
            attributedPlaceholder = NSAttributedString(string: placeholderFinal,
                                                       attributes: [NSAttributedString.Key.foregroundColor:color])
        }
    }
    
    override public var attributedPlaceholder: NSAttributedString?{
        didSet{ lblFloatPlaceholder.text = placeholderFinal }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public func showError(message:String? = nil) {
        if let msg = message { errorMessage = msg }
        showErrorLabel = true
    }
    
    public func hideError()  {
        showErrorLabel = false
    }
    
    public var isNew: Bool = false {
        didSet {
            updateNewLabelVisibility()
        }
    }
    
    private let newLabel: UILabel = {
        let label = UILabel()
        label.text = "New"
        //label.font = FontFamily.Metropolis.semiBold.font(size: 9)
        label.textColor = .white
        //label.backgroundColor = Asset.color3F8A7E.color
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    fileprivate func commonInit() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true

        //MARK: - Remove undo and redo option from keyboard
        if #available(iOS 9.0, *) {
            let item = self.inputAssistantItem
            item.leadingBarButtonGroups = []
        }

        ntborderStyle               = .none
        dtLayer.backgroundColor     = UIColor.clear.cgColor
        
        floatPlaceholderColor       = UIColor.black.withAlphaComponent(0.65)
        floatPlaceholderActiveColor = UIColor.black.withAlphaComponent(0.65)
        lblFloatPlaceholder.frame   = CGRect.zero
        lblFloatPlaceholder.alpha   = 0.0
        lblFloatPlaceholder.font    = floatPlaceholderFont
        lblFloatPlaceholder.text    = placeholderFinal
        
        addSubview(lblFloatPlaceholder)
        
        lblError.frame              = CGRect.zero
        lblError.font               = errorFont
        lblError.textColor          = errorTextColor
        lblError.numberOfLines      = 0
        lblError.isHidden           = true
        
        addSubview(lblError)
        
        delegate = self
        self.setupAsciKeybaord()
        layer.insertSublayer(dtLayer, at: 0)
    }
    
    func setupAsciKeybaord(){
        //TODO: DISABLE EMOJI KEYBOARD
        if keyboardType == .default || keyboardType == .emailAddress {
            keyboardType = .asciiCapable// FOR NOT ALLOW EMOJI IN KEYBOARD
        } else {
            keyboardType = keyboardType
        }
        //        } else {
        //            keyboardType = .default
        //        }
    }
    
    fileprivate func showErrorMessage(){
        lblError.text = errorMessage
        lblError.isHidden = false
        let boundWithPadding = CGSize(width: bounds.width - (paddingX * 2), height: bounds.height)
        lblError.frame = CGRect(x: paddingX, y: 0, width: boundWithPadding.width, height: boundWithPadding.height)
        lblError.sizeToFit()
        invalidateIntrinsicContentSize()
    }
    
    func setErrorLabelAlignment() {
        var newFrame = lblError.frame
        if textAlignment == .right {
            newFrame.origin.x = bounds.width - paddingX - newFrame.size.width
        }else if textAlignment == .left{
            newFrame.origin.x = paddingX
        }else if textAlignment == .center{
            newFrame.origin.x = (bounds.width / 2.0) - (newFrame.size.width / 2.0)
        }else if textAlignment == .natural{
            
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft{
                newFrame.origin.x = bounds.width - paddingX - newFrame.size.width
            }
        }
        lblError.frame = newFrame
    }
    
    func setFloatLabelAlignment() {
        var newFrame = lblFloatPlaceholder.frame
        if textAlignment == .right {
            newFrame.origin.x = bounds.width - paddingX - newFrame.size.width
        }else if textAlignment == .left{
            newFrame.origin.x = paddingX
        }else if textAlignment == .center{
            newFrame.origin.x = (bounds.width / 2.0) - (newFrame.size.width / 2.0)
        }else if textAlignment == .natural{
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft{
                newFrame.origin.x = bounds.width - paddingX - newFrame.size.width
            }
        }
        lblFloatPlaceholder.frame = newFrame
    }
    
    fileprivate func hideErrorMessage(){
        lblError.text = ""
        lblError.isHidden = true
        lblError.frame = CGRect.zero
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func showFloatingLabel(_ animated:Bool) {
        let animations:(()->()) = {
            self.lblFloatPlaceholder.alpha = 1.0
            self.lblFloatPlaceholder.frame = CGRect(x: self.lblFloatPlaceholder.frame.origin.x,
                                                    y: self.paddingYFloatLabel,
                                                    width: self.lblFloatPlaceholder.bounds.size.width,
                                                    height: self.lblFloatPlaceholder.bounds.size.height)
        }
        
        if animated && animateFloatPlaceholder {
            UIView.animate(withDuration: floatingLabelShowAnimationDuration,
                           delay: 0.0,
                           options: [.beginFromCurrentState,.curveEaseOut],
                           animations: animations){ status in
                            DispatchQueue.main.async {
                                self.layoutIfNeeded()
                            }
            }
        }else{
            animations()
        }
    }
    
    fileprivate func hideFlotingLabel(_ animated:Bool) {
        let animations:(()->()) = {
            self.lblFloatPlaceholder.alpha = 0.0
            self.lblFloatPlaceholder.frame = CGRect(x: self.lblFloatPlaceholder.frame.origin.x,
                                                    y: self.lblFloatPlaceholder.font.lineHeight,
                                                    width: self.lblFloatPlaceholder.bounds.size.width,
                                                    height: self.lblFloatPlaceholder.bounds.size.height)
        }
        
        if animated && animateFloatPlaceholder {
            UIView.animate(withDuration: floatingLabelShowAnimationDuration,
                           delay: 0.0,
                           options: [.beginFromCurrentState,.curveEaseOut],
                           animations: animations){ status in
                            DispatchQueue.main.async {
                                self.layoutIfNeeded()
                            }
            }
        }else{
            animations()
        }
    }
    
    fileprivate func insetRectForEmptyBounds(rect:CGRect) -> CGRect{
        let newX = x
        guard showErrorLabel else { return CGRect(x: newX, y: 0, width: rect.width - newX - paddingX, height: rect.height) }
        
        let topInset = (rect.size.height - lblError.bounds.size.height - paddingYErrorLabel - fontHeight) / 2.0
        let textY = topInset - ((rect.height - fontHeight) / 2.0)
        
        return CGRect(x: newX, y: floor(textY), width: rect.size.width - newX - paddingX, height: rect.size.height)
    }
    
    fileprivate func insetRectForBounds(rect:CGRect) -> CGRect {
        
        guard let placeholderText = lblFloatPlaceholder.text,!placeholderText.isEmptyStr  else {
            return insetRectForEmptyBounds(rect: rect)
        }
        
        if floatingDisplayStatus == .never {
            return insetRectForEmptyBounds(rect: rect)
        }else{
            
            if let text = text,text.isEmptyStr && floatingDisplayStatus == .defaults {
                return insetRectForEmptyBounds(rect: rect)
            }else{
                let topInset = paddingYFloatLabel + lblFloatPlaceholder.bounds.size.height + (paddingHeight / 2.0)
                let textOriginalY = (rect.height - fontHeight) / 2.0
                var textY = topInset - textOriginalY
                
                if textY < 0 && !showErrorLabel { textY = topInset }
                let newX = x
                return CGRect(x: newX, y: ceil(textY), width: rect.size.width - newX - paddingX, height: rect.height)
            }
        }
    }
    
    @objc fileprivate func textFieldTextChanged(){
        guard hideErrorWhenEditing && showErrorLabel else { return }
        showErrorLabel = false
    }
    
    override public var intrinsicContentSize: CGSize{
        self.layoutIfNeeded()
        
        let textFieldIntrinsicContentSize = super.intrinsicContentSize
        
        if showErrorLabel {
            lblFloatPlaceholder.sizeToFit()
            return CGSize(width: textFieldIntrinsicContentSize.width,
                          height: textFieldIntrinsicContentSize.height + paddingYFloatLabel + paddingYErrorLabel + lblFloatPlaceholder.bounds.size.height + lblError.bounds.size.height + paddingHeight)
        }else{
            return CGSize(width: textFieldIntrinsicContentSize.width,
                          height: textFieldIntrinsicContentSize.height + paddingYFloatLabel + lblFloatPlaceholder.bounds.size.height + paddingHeight)
        }
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return insetRectForBounds(rect: rect)
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return insetRectForBounds(rect: rect)
    }
    
    fileprivate func insetForSideView(forBounds bounds: CGRect) -> CGRect{
        var rect = bounds
        rect.origin.y = 0
        rect.size.height = dtLayerHeight
        return rect
    }
    
    override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.leftViewRect(forBounds: bounds)
        return insetForSideView(forBounds: rect)
    }
    
    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.rightViewRect(forBounds: bounds)
        return insetForSideView(forBounds: rect)
    }
    
    override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect.origin.y = (dtLayerHeight - rect.size.height) / 2
        return rect
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        dtLayer.frame = CGRect(x: bounds.origin.x,
                               y: bounds.origin.y,
                               width: bounds.width,
                               height: dtLayerHeight)
        let borderStype = ntborderStyle
        ntborderStyle = borderStype
        CATransaction.commit()
        
        if showErrorLabel {
            
            var lblErrorFrame = lblError.frame
            lblErrorFrame.origin.y = dtLayer.frame.origin.y + dtLayer.frame.size.height + paddingYErrorLabel
            lblError.frame = lblErrorFrame
        }
        
        let floatingLabelSize = lblFloatPlaceholder.sizeThatFits(lblFloatPlaceholder.superview!.bounds.size)
        
        lblFloatPlaceholder.frame = CGRect(x: x, y: lblFloatPlaceholder.frame.origin.y,
                                           width: floatingLabelSize.width,
                                           height: floatingLabelSize.height)
        
        setErrorLabelAlignment()
        setFloatLabelAlignment()
        lblFloatPlaceholder.textColor = isFirstResponder ? floatPlaceholderActiveColor : floatPlaceholderColor
        
        switch floatingDisplayStatus {
        case .never:
            hideFlotingLabel(isFirstResponder)
        case .always:
            showFloatingLabel(isFirstResponder)
        default:
            if let enteredText = text,!enteredText.isEmptyStr{
                showFloatingLabel(isFirstResponder)
            }else{
                hideFlotingLabel(isFirstResponder)
            }
        }
        
        // Positioning the "New" label at top-right
        let labelHeight: CGFloat = 18
        let labelWidth: CGFloat = 36
        newLabel.frame = CGRect(
            x: lblFloatPlaceholder.frame.width + 8,
            y: IS_IPHONE ? lblFloatPlaceholder.frame.origin.y - 3 : lblFloatPlaceholder.frame.origin.y,
            width: labelWidth,
            height: labelHeight
        )
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
    
    public func isNumber(textToValidate: String) -> Bool {
        let num = Int(textToValidate)
        if num != nil {
            return true
        }
        return false
    }
    
    public func hasSpecialCharacter(searchTerm: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
        if regex.firstMatch(in: searchTerm, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, searchTerm.count)) != nil {
            return true
        }
        return false
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
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions(), context: nil)
        
        self.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        addSubview(newLabel)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        applyFilter(textField: textField)
        updateNewLabelVisibility()
    }
    
    private func updateNewLabelVisibility() {
        guard isNew else {
            newLabel.isHidden = true
//            lblFloatPlaceholder.text = placeholderFinal
            return
        }
        
        if let text = self.text, text.isEmpty {
            // Show in placeholder style if needed (optional)
            newLabel.isHidden = true
//            lblFloatPlaceholder.text = placeholderFinal
        } else {
            // Show on top right when text exists
            newLabel.isHidden = false
            lblFloatPlaceholder.text = lblFloatPlaceholder.text?.replacingOccurrences(of: "*", with: "")
        }
    }
}

extension NTTextField {
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            if self.isSecureTextEntry {
                if validationType == .PASSWORD_PASTE || validationType == .CONFIRM_PASSWORD_PASTE {
                    return true
                } else {
                    return false
                }
            } else {
                if validationType == .PASSWORD || validationType == .CONFIRM_PASSWORD {
                    return false
                }
            }
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension NTTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.data(using: .ascii) != nil {
            // Conversion to ASCII succeeded, so allow the text change
            return true
        } else {
            // Conversion to ASCII failed, so prevent the text change
            return false
        }
    }
}

//MARK: - Validation setup for numbers value also not allow
extension NTTextField {
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupValidation()
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, let filterFunction = filterFunction else { return }
        let filteredText = filterFunction(text)
        // Enforce the maxLength based on validationType
        if filteredText.count > characterLimit {
            let limitedText = String(filteredText.prefix(characterLimit))
            textField.text = limitedText
        } else {
            textField.text = filteredText
        }
    }
    
    private func setupValidation() {
        switch validationType {
        case .DEFAULT:
            filterFunction = { text in
                let resultText = text.allowASCII()
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .INVITATION_CODE:
            keyboardType = .numberPad
            filterFunction = { text in
                // Remove all non-letter and non-space characters
                let cleanedText = text.components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted).joined()
                // Ensure no space at the start of the string
                return cleanedText.hasPrefix(" ") ? String(cleanedText.dropFirst()) : cleanedText
            }
        case .FIRST_NAME:
            characterLimit = 50
            filterFunction = { text in
                // Remove all non-letter and non-space characters
                let cleanedText = text.components(separatedBy: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted).joined()
                // Ensure no space at the start of the string
                return cleanedText.hasPrefix(" ") ? String(cleanedText.dropFirst()) : cleanedText
            }
        case .MIDDLE_NAME:
            characterLimit = 50
            filterFunction = { text in
                // Remove all non-letter and non-space characters
                let cleanedText = text.components(separatedBy: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted).joined()
                // Ensure no space at the start of the string
                return cleanedText.hasPrefix(" ") ? String(cleanedText.dropFirst()) : cleanedText
            }
        case .LAST_NAME:
            characterLimit = 50
            filterFunction = { text in
                // Remove all non-letter and non-space characters
                let cleanedText = text.components(separatedBy: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted).joined()
                // Ensure no space at the start of the string
                return cleanedText.hasPrefix(" ") ? String(cleanedText.dropFirst()) : cleanedText
            }
        case .EMAIL:
            filterFunction = { text in
                let resultText = text.allowASCII()
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .MOBILE_NUMBER:
            filterFunction = { text in
                return text.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            }
        case .FAX:
            filterFunction = { text in
                return text.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            }
        case .TITLE:
            filterFunction = { text in
                //return text.components(separatedBy: CharacterSet.letters.inverted).joined()
                let cleanedText = text.components(separatedBy: CharacterSet.letters.union(.whitespaces).inverted).joined()
                
                // Replace multiple spaces with a single space
                let resultText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
                
                // Ensure no space at the start of the string
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .NPI:
            keyboardType = .numberPad
            characterLimit = 10
            filterFunction = { text in
                // Remove all non-letter and non-space characters
                let cleanedText = text.components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted).joined()
                // Ensure no space at the start of the string
                return cleanedText.hasPrefix(" ") ? String(cleanedText.dropFirst()) : cleanedText
            }
        case .PASSWORD:
            filterFunction = { text in
                return text.allowASCII()
            }
        case .CONFIRM_PASSWORD:
            filterFunction = { text in
                return text.allowASCII()
            }
        case .PASSWORD_PASTE:
            filterFunction = { text in
                return text.allowASCII()
            }
        case .CONFIRM_PASSWORD_PASTE:
            filterFunction = { text in
                return text.allowASCII()
            }
        case .SEARCH:
            filterFunction = { text in
                let resultText = text.allowASCII()
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .MRN:
            characterLimit = 20
            filterFunction = { text in
                // Remove all non-letter and non-space characters
                let cleanedText = text.components(separatedBy: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789").inverted).joined()
                // Ensure no space at the start of the string
                return cleanedText.hasPrefix(" ") ? String(cleanedText.dropFirst()) : cleanedText
            }
        case .GROUP_NAME:
            characterLimit = 30
            filterFunction = { text in
//                let cleanedText = text.components(separatedBy: CharacterSet.letters.union(.whitespaces).inverted).joined()
                
                let customSet = CharacterSet.letters.union(.whitespaces).union(CharacterSet(charactersIn: "-/:0123456789"))
                let cleanedText = text.components(separatedBy: customSet.inverted).joined()

                // Replace multiple spaces with a single space
                let resultText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
                
                // Ensure no space at the start of the string
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .BROADCAST_NAME:
            characterLimit = 30
            filterFunction = { text in
                let cleanedText = text.components(separatedBy: CharacterSet.letters.union(.whitespaces).inverted).joined()
                
                // Replace multiple spaces with a single space
                let resultText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
                
                // Ensure no space at the start of the string
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .MINI_GROUP_NAME:
            characterLimit = 50
            filterFunction = { text in
                let cleanedText = text.components(separatedBy: CharacterSet.letters.union(.whitespaces).inverted).joined()
                
                // Replace multiple spaces with a single space
                let resultText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
                
                // Ensure no space at the start of the string
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .EMR:
            characterLimit = 20
            filterFunction = { text in
                let cleanedText = text.components(separatedBy: CharacterSet.letters.union(.whitespaces).inverted).joined()
                
                // Replace multiple spaces with a single space
                let resultText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
                
                // Ensure no space at the start of the string
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .STREET_NUMBER_NAME:
            characterLimit = 30
            filterFunction = { text in
                let cleanedText = text.allowASCII()
                let resultText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .CITY:
            characterLimit = 20
            filterFunction = { text in
                let cleanedText = text.allowASCII()
                let resultText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .APPARTMENT:
            characterLimit = 5
            filterFunction = { text in
                let cleanedText = text.allowASCII()
                let resultText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .SUIT:
            characterLimit = 5
            filterFunction = { text in
                let cleanedText = text.allowASCII()
                let resultText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        case .ZIPCODE:
            characterLimit = 5
            filterFunction = { text in
                let cleanedText = text.components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted).joined()
                // Ensure no space at the start of the string
                return cleanedText.hasPrefix(" ") ? String(cleanedText.dropFirst()) : cleanedText
            }
        }
    }
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
        default :
            filterFunction = { text in
                let resultText = text.allowASCII()
                return resultText.hasPrefix(" ") ? String(resultText.dropFirst()) : resultText
            }
        }
    }
}
