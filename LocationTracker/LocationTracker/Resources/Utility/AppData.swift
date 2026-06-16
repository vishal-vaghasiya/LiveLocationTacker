//
//  AppData.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 11/08/25.
//

import Foundation
import UIKit
class AppData {
    
    static let shared: AppData = {
        let instance = AppData()
        return instance
    }()
    
    var selectedCircleInfo: CircleInfo?
    var activeChildCircle = CircleInfo()
}
