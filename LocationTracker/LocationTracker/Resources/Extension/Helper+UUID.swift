//
//  Helper+UUID.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 14/08/25.
//

import Foundation

extension UUID {
    var short15: String {
        String(self.uuidString.replacingOccurrences(of: "-", with: "").prefix(15))
    }
}
