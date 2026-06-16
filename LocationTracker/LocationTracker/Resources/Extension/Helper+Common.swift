//
//  Helper+Common.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//

import UIKit

extension UICollectionViewCell {
    static var identifier:String{
        return String(describing: self)
    }
    
    static var identifier_iPad:String {
        let identifier = String(describing: self)
        return identifier + "_iPad"
    }
}

extension UITableViewCell {
    static var identifier:String{
        return String(describing: self)
    }
    
    static var identifier_iPad:String {
        let identifier = String(describing: self)
        return identifier + "_iPad"
    }
}
