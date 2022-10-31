//
//  Share.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation

struct Share: Codable {
    let shareId: String
    let author: User
    let description: String
    let bestBefore: Date
    let dueDate: Date
    let place: String
    let imageURL: String
}
