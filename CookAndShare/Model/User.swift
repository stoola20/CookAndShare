//
//  User.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let imageURL: String
    let recipesId: [String]
    let sharesId: [String]
    let conversationId: [String]
}
