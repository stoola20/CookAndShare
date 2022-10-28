//
//  Recipe.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation
import FirebaseFirestore

struct Recipe: Codable {
    let recipeId: String
    let authorId: String
    let cookDuration: Timestamp
    let time: Timestamp
    let title: String
    let mainImageURL: String
    let description: String
    let quantity: Int
    let ingredients: [Ingredient]
    let procedures: [Procedure]
    let likes: Int
}

struct Ingredient: Codable {
    let name: String
    let quantity: String
}

struct Procedure: Codable {
    let step: Int
    let description: String
    let imageURL: String
}
