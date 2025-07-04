//
//  CoredataManager.swift
//
//  Created by DREAMWORLD on 19/09/24.
//

import Foundation
import CoreData


//let favCommandData = CommandData<FavCommand>()
//let customCommandData = CommandData<CustomCommand>()
//let translateCommandData = CommandData<Favourite>()


class CommandData<T: NSManagedObject> {
    
    func saveData(context: NSManagedObjectContext, file: T) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            print("Error saving data: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchData(context: NSManagedObjectContext, completion: @escaping ([T]) -> ()) {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        do {
            let result = try context.fetch(fetchRequest)
            completion(result)
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            completion([])
        }
    }
    
    func deleteData(context: NSManagedObjectContext, id:String, predictText:String) -> Bool {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = NSPredicate(format: "\(id) == %@",predictText)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for object in results {
                context.delete(object)
            }
            
            try context.save()
            
            return true
        } catch {
            print("Error deleting data: \(error.localizedDescription)")
            return false
        }
    }
}
