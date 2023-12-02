//
//  CoreDataStack.swift
//  DrawingApp
//
//  Created by Martin Krcma on 23.11.2023.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ImageModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent store: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Failed to save context: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
