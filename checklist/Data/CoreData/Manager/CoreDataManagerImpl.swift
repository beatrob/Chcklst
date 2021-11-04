//
//  CoreDataManager.swift
//  checklist
//
//  Created by Róbert Konczi on 27/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit


class CoreDataManagerImpl: CoreDataManager {
    
    // MARK: - Core Data stack

    private var persistentContainer: NSPersistentContainer?
    
    func getViewContext() -> Promise<NSManagedObjectContext> {
        guard let context = persistentContainer?.viewContext else {
            return .init(error: CoreDataError.nilViewContext)
        }
        return .value(context)
    }
    
    
    func initialize() -> Promise<Void> {
        Promise { resolver in
            let container = NSPersistentContainer(name: "checklist")
            container.loadPersistentStores { [weak self] (storeDescription, error) in
                if let error = error {
                    resolver.reject(error)
                }
                self?.persistentContainer = container
                resolver.fulfill(())
            }
        }
    }

    // MARK: - Core Data Saving support

    func saveContext() -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void >in
            if context.hasChanges {
                try context.save()
            }
            return .value
        }
    }
}


// MARK: - Private methods

private extension CoreDataManagerImpl {
    
}
