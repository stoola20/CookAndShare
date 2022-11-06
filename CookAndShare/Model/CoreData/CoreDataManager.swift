//
//  CoreDataManager.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager(modelName: Constant.modelName)
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }

    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    lazy var managedContext: NSManagedObjectContext = CoreDataManager.shared.storeContainer.viewContext

    func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func addItem(name: String, quantity: String) {
        let entity = NSEntityDescription.entity(forEntityName: Constant.entityName, in: managedContext)!
        let item = ShoppingList(entity: entity, insertInto: managedContext)
        item.name = name
        item.quantity = quantity
        saveContext()
    }
    
    func deleteItem(item: ShoppingList) {
        managedContext.delete(item)
        saveContext()
    }
    
    func fetchItem() -> [ShoppingList]? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constant.entityName)
        
        do {
            guard let shoppingItems = try managedContext.fetch(fetchRequest) as? [ShoppingList]
            else { fatalError("Could not downcast to [ShoppingList]")}
            return shoppingItems
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
}
