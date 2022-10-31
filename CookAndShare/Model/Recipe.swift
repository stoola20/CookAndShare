//
//  Recipe.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Recipe: Codable {
    var recipeId = String.empty
    var authorId = String.empty
    var cookDuration: Int = 0
    var time = Timestamp()
    var title = String.empty
    var mainImageURL = String.empty
    var description = String.empty
    var quantity: Int = 0
    var ingredientNames: [String] = []
    var ingredients: [Ingredient] = []
    var procedures: [Procedure] = []
    var likes: [String] = []
    var saves: [String] = []
}

struct Ingredient: Codable {
    var name = String.empty
    var quantity = String.empty
}

struct Procedure: Codable {
    var step: Int = 1
    var description = String.empty
    var imageURL = String.empty
}
