//
//  User.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation

struct User: Codable, Hashable {
    var id = String.empty
    var name = String.empty
    var email = String.empty
    var imageURL = String.empty
    var fcmToken = String.empty
    var recipesId: [String] = []
    var savedRecipesId: [String] = []
    var sharesId: [String] = []
    var conversationId: [String] = []
    var blockList: [String] = []
}
