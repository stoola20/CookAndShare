//
//  Recipe.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation
import FirebaseFirestore

struct Recipe: Codable {
    var recipeId: String = String.empty
    var authorId: String = String.empty
    var cookDuration: Int = 0
    var time: Timestamp = Timestamp()
    var title: String = String.empty
    var mainImageURL: String = String.empty
    var description: String = String.empty
    var quantity: Int = 0
    var ingredients: [Ingredient] = []
    var procedures: [Procedure] = []
    var likes: Int = 0
}

struct Ingredient: Codable {
    var name: String = String.empty
    var quantity: String = String.empty
}

struct Procedure: Codable {
    var step: Int = 1
    var description: String = String.empty
    var imageURL: String = String.empty
}
