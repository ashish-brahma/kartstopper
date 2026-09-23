//
//  Persistence.swift
//  Kartstopper
//
//  Created by Ashish Brahma on 16/09/25.
//
//  A structure that sets up the Core Data stack.

import CoreData
internal import OSLog

struct PersistenceController {
    static let shared = PersistenceController()
    
    let logger = Logger(subsystem: "com.goldendamsel.kartstopper", category: "persistence")
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Warehouse")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        logger.debug("Successfully loaded persistent stores.")
        
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = false
    }
}
