//
//  ShoppingList+CoreDataProperties.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
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

}

extension ShoppingList : Identifiable {

}
