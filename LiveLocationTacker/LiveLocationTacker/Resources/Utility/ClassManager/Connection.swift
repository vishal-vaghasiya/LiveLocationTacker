//
//  Connection.swift
//
//

import Foundation
import Reachability
class ConnectionManager {
    
    static let sharedInstance = ConnectionManager()
    private var reachability : Reachability!
    
    func observeReachability(){
        do {
            self.reachability =  try Reachability()
            NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
            do {
                try self.reachability.startNotifier()
            }
            catch(let error) {
                print("Error occured while starting reachability notifications : \(error.localizedDescription)")
            }
        } catch {
            print(error)
        }
    }
    
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            NotificationCenter.default.post(name: Notification.Name("internetReachable"), object: nil)
            print("Network available via Cellular Data.")
            break
        case .wifi:
            print("Network available via WiFi.")
            NotificationCenter.default.post(name: Notification.Name("internetReachable"), object: nil)
            break
        case .none:
            NotificationCenter.default.post(name: Notification.Name("internetNotReachable"), object: nil)
            print("Network is not available.")
            break
        case .unavailable:
            NotificationCenter.default.post(name: Notification.Name("internetNotReachable"), object: nil)
            print("Network is  unavailable.")
            break
        }
    }
}
