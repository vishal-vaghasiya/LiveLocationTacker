//
//  NetworkMonitor.swift
//  LocationTracker
//
//  Created by Nexios Mac 4 on 08/09/25.
//

import Foundation
import UIKit
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    var isConnected: Bool = true
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
