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
        guard let entity = NSEntityDescription.entity(forEntityName: Constant.entityName, in: managedContext)
        else { return }
        let item = ShoppingList(entity: entity, insertInto: managedContext)
        item.name = name
        item.quantity = quantity
        item.done = false
        saveContext()
    }

    func updateItem(name: String, quantity: String, done: Bool) {
        let request = ShoppingList.fetchRequest() as NSFetchRequest<ShoppingList>
        request.predicate = NSPredicate(format: "name = %@ AND quantity = %@", name, quantity)

        do {
            let existedIngredient = try managedContext.fetch(request)
//            if existedIngredient.count == 1 {
                let ingredientToUpdate = existedIngredient[0]
                ingredientToUpdate.done = done
                saveContext()
//            }
        } catch {
            print(error)
        }
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
