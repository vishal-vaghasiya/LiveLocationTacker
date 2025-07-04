//
//  Helper+Common.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 04/07/25.
//

import UIKit

extension UITableViewCell {
    static var identifier:String{
        return String(describing: self)
    }
    
    static var identifier_iPad:String {
        let identifier = String(describing: self)
        return identifier + "_iPad"
    }
}

extension UITableViewHeaderFooterView {
    static var identifier:String{
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    static var identifier:String{
        return String(describing: self)
    }
    
    static var identifier_iPad:String {
        let identifier = String(describing: self)
        return identifier + "_iPad"
    }
}
