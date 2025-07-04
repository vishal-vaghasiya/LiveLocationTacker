//
//  Helper+Date.swift
//  LiveLocationTacker
//
//  Created by Nexios Technologies on 04/07/25.
//

import Foundation

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
