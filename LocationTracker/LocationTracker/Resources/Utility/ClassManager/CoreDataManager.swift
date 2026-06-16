//
//  CoreDataManager.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 13/08/25.
//

import UIKit
import CoreData
import UserNotifications

/*
 // Get all
 let alerts = CoreDataManager.shared.fetchProximityAlerts()

 // Delete by ID
 if let id = alerts.first?.id {
     CoreDataManager.shared.deleteProximityAlert(by: id)
 }

 // Update by ID
 if let id = alerts.first?.id {
     CoreDataManager.shared.updateProximityAlert(by: id, name: "New Name", radius: 200)
 }
 */

final class CoreDataManager {
    
    // MARK: - Singleton
    static let shared = CoreDataManager()
    private init() {}
    
    // MARK: - Context
    private var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found.")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Save Proximity Alert
    func saveProximityAlert(name: String,
                            location: String,
                            type: Int64,
                            latitude: Double,
                            longitude: Double,
                            radius: Double,
                            dateTime: Date,
                            pushNotification: Bool,
                            note: String,
                            completion: ((Bool, String) -> Void)? = nil) {
        
        let alert = ProximityAlert(context: context)
        alert.id = UUID()
        alert.name = name
        alert.location = location
        alert.type = type
        alert.latitude = latitude
        alert.longitude = longitude
        alert.radius = radius
        alert.dateTime = dateTime
        alert.pushNotification = pushNotification
        alert.note = note
        alert.radiusTrigger = false
        alert.date = Date()
        
        do {
            try context.save()
            print("✅ Proximity Alert saved.")
            completion?(true, "Proximity alert '\(name)' saved successfully.")
            if pushNotification {
                let content = UNMutableNotificationContent()
                content.title = "Proximity Alert"
                content.body = "You have an alert for \(name) at \(location)"
                content.sound = .default

                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                  from: dateTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

                let request = UNNotificationRequest(identifier: alert.id?.uuidString ?? UUID().uuidString,
                                                    content: content,
                                                    trigger: trigger)

                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Failed to schedule notification:", error.localizedDescription)
                    } else {
                        print("📅 Notification scheduled for \(dateTime)")
                    }
                }
            }
        } catch {
            print("❌ Failed to save:", error.localizedDescription)
            completion?(false, "Failed to save proximity alert '\(name)': \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch All Alerts
    func fetchProximityAlerts() -> [ProximityAlert] {
        let request: NSFetchRequest<ProximityAlert> = ProximityAlert.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        do {
            let allAlerts = try context.fetch(request)
            let now = Date()
            let upcoming = allAlerts.filter { ($0.dateTime ?? now) >= now }
            let past = allAlerts.filter { ($0.dateTime ?? now) < now }
            return upcoming + past
        } catch {
            print("❌ Fetch failed:", error.localizedDescription)
            return []
        }
    }
    
    // MARK: - Delete Alert
    func deleteProximityAlert(by id: UUID) {
        let request: NSFetchRequest<ProximityAlert> = ProximityAlert.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let alertToDelete = results.first {
                let identifier = alertToDelete.id?.uuidString ?? ""
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                context.delete(alertToDelete)
                try context.save()
                print("🗑️ Alert with ID \(id) deleted.")
            } else {
                print("⚠️ No alert found with ID \(id)")
            }
        } catch {
            print("❌ Delete failed:", error.localizedDescription)
        }
    }
    
    func updateProximityAlert(by id: UUID,
                              name: String? = nil,
                              location: String? = nil,
                              type: Int64? = nil,
                              latitude: Double? = nil,
                              longitude: Double? = nil,
                              radius: Double? = nil,
                              dateTime: Date? = nil,
                              pushNotification: Bool? = nil,
                              note: String? = nil,
                              completion: ((Bool, String) -> Void)? = nil) {
        
        let request: NSFetchRequest<ProximityAlert> = ProximityAlert.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let alert = try context.fetch(request).first {
                if let name = name { alert.name = name }
                if let location = location { alert.location = location }
                if let type = type { alert.type = type }
                if let latitude = latitude { alert.latitude = latitude }
                if let longitude = longitude { alert.longitude = longitude }
                if let radius = radius { alert.radius = radius }
                if let dateTime = dateTime { alert.dateTime = dateTime }
                if let pushNotification = pushNotification { alert.pushNotification = pushNotification }
                if let note = note { alert.note = note }
                alert.radiusTrigger = false
                
                try context.save()
                print("✏️ Alert with ID \(id) updated.")
                completion?(true, "Proximity alert '\(alert.name ?? "")' updated successfully.")
                
                if let pushNotification = pushNotification, pushNotification == true, let dateTime = dateTime {
                    let center = UNUserNotificationCenter.current()
                    let identifier = alert.id?.uuidString ?? ""
                    center.removePendingNotificationRequests(withIdentifiers: [identifier])
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Proximity Alert"
                    content.body = "You have an alert for \(alert.name ?? "") at \(alert.location ?? "")"
                    content.sound = .default
                    
                    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                      from: dateTime)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: identifier,
                                                        content: content,
                                                        trigger: trigger)
                    
                    center.add(request) { error in
                        if let error = error {
                            print("❌ Failed to schedule notification:", error.localizedDescription)
                        } else {
                            print("📅 Notification scheduled for \(dateTime)")
                        }
                    }
                }
            } else {
                print("⚠️ No alert found with ID \(id)")
                completion?(false, "No alert found with ID \(id). Update not performed.")
            }
        } catch {
            print("❌ Update failed:", error.localizedDescription)
            completion?(false, "Failed to update alert: \(error.localizedDescription)")
        }
    }
    
    func markAlertAsRadiusTriggered(by id: UUID,
                                    radiusTrigger: Bool? = nil,
                                    note: String? = nil) {
        let request: NSFetchRequest<ProximityAlert> = ProximityAlert.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let alert = try context.fetch(request).first {
                if let radiusTrigger = radiusTrigger { alert.radiusTrigger = radiusTrigger }
                
                try context.save()
                let statusText = radiusTrigger == true ? "triggered" : "reset"
                print("📍 Radius trigger for alert '\(alert.name ?? "")' has been \(statusText).")
            } else {
                print("⚠️ No alert found with ID \(id)")
            }
        } catch {
            print("❌ Failed to update radius trigger:", error.localizedDescription)
        }
    }
    
}
