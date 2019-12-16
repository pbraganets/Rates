//
//  RatesCoreDataProviver.swift
//  Rates
//
//  Created by Pavel B on 12/15/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//

import Foundation
import CoreData

class RatesCoreDataProvider: RatesProvider, RatesStorage {
    
    // MARK: - Private properties
    
    static private let ratesError = NSError(domain: "RatesCoreDataProvider", code: 0, userInfo: nil)
    private let modelName = "Rates"
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Failed to find data model")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }

        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent("\(self.modelName).sqlite")

        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption : true
            ]

            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: options)
        } catch {
            fatalError("Error configuring persistent store: \(error)")
        }

        return persistentStoreCoordinator
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()
    
    private lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        managedObjectContext.parent = self.privateManagedObjectContext

        return managedObjectContext
    }()
    
    // MARK: - RatesProvider protocol implementation
    
    func ratesList(completion: @escaping ([(String, Double)]?, Error?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let fetchRequest: NSFetchRequest<Rate> = Rate.fetchRequest()
                let rates = try self.mainManagedObjectContext.fetch(fetchRequest)
                completion(rates.map {($0.name, $0.value)}, nil)
            } catch let error as NSError {
                print("Could not fetch \(error)")
                completion(nil, RatesCoreDataProvider.ratesError)
            }
        }
    }
    
    // MARK: - RatesStorage protocol implementation
    
    func storeRates(_ rates: [(String, Double)], completion: ((_ result: Bool, _ error: Error?) -> Void)?) {
        let backgroundContext = backgroundManagedObjectContext()
        backgroundContext.performAndWait {
            do {
                for rate in rates {
                    let fetchRequest: NSFetchRequest<Rate> = Rate.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "name = %@", rate.0)
                    let rates = try backgroundContext.fetch(fetchRequest)
                    if rates.count != 0 {
                        let rateCD = rates[0]
                        rateCD.value = rate.1
                    } else {
                        let rateCD = NSEntityDescription.insertNewObject(forEntityName: "Rate", into: backgroundContext) as! Rate
                        rateCD.name = rate.0
                        rateCD.value = rate.1
                    }
                }
                
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
                self.saveChanges(completion: completion)
                
            } catch let error as NSError {
                print("Could not update \(error)")
                completion?(false, RatesCoreDataProvider.ratesError)
            }
        }
    }
    
    // MARK: - Private functions
    
    private func saveChanges(completion: ((_ result: Bool, _ error: Error?) -> Void)?) {
        mainManagedObjectContext.performAndWait {
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
            } catch {
                print("\(error), \(error.localizedDescription)")
                completion?(false, RatesCoreDataProvider.ratesError)
            }
        }

        privateManagedObjectContext.perform {
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
                
                completion?(true, nil)
            } catch {
                print("\(error), \(error.localizedDescription)")
                completion?(false, RatesCoreDataProvider.ratesError)
            }
        }
    }
    
    private func backgroundManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = mainManagedObjectContext
        
        return managedObjectContext
    }
}
