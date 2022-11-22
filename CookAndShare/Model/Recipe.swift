//
//  Recipe.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Recipe: Codable, Hashable {
    var recipeId = String.empty
    var authorId = String.empty
    var cookDuration: Int = 10
    var time = Timestamp()
    var title = String.empty
    var mainImageURL = String.empty
    var description = String.empty
    var quantity: Int = 1
    var ingredientNames: [String] = []
    var ingredients: [Ingredient] = []
    var procedures: [Procedure] = []
    var likes: [String] = []
    var saves: [String] = []
    var reports: [String] = []

    func hash(into hasher: inout Hasher) {
        hasher.combine(recipeId)
    }

    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.recipeId == rhs.recipeId
    }
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
