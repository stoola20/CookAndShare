//
//  ShoppingList+CoreDataProperties.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/20.
//
//

import Foundation
import CoreData

extension ShoppingList {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingList> {
        return NSFetchRequest<ShoppingList>(entityName: "ShoppingList")
    }

    @NSManaged public var name: String
    @NSManaged public var quantity: String
    @NSManaged public var done: Bool
}

extension ShoppingList : Identifiable {
}
