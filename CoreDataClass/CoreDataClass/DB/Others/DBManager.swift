//
//  DBManager.swift
//  CoreDataClass
//
//  Created by zs-mac-4 on 26/10/22.
//

import Foundation
import CoreData


class DBManager : NSObject{
    
    
    lazy var persistentContainer: NSPersistentContainer = {
            
            let container = NSPersistentContainer(name: "PeopleDB")
        
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        
        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    
    
    
    func createPeople(name : String, age : UInt32, city : String){
        
        let context = persistentContainer.viewContext //store keeper
        
        let peopleDesc = NSEntityDescription.entity(forEntityName: "People", in: context)!
        
         let managedObject = NSManagedObject(entity: peopleDesc, insertInto: context)
        
        managedObject.setValue(name, forKey: "name")
        managedObject.setValue(age, forKey: "age")
        managedObject.setValue(city, forKey: "city")
        
        saveContext()
            
    }
    
    
    func fetchPeople()->[NSManagedObject]{
        let context = persistentContainer.viewContext //store keeper
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "People")
        
        
        do {
            let result = try? context.fetch(fetchRequest)
            return result as! [NSManagedObject]
        }
        
        
        
    }
    
    
    
    func updateName(with name : String){
        
        let people = fetchPeople()
        
        for person in people{
            person.setValue(name, forKey: "name")
        }
        
        saveContext()
        
    }
    
    
    func delete(obj : NSManagedObject){
        
        persistentContainer.viewContext.delete(obj)
        saveContext()
    }
    
}
