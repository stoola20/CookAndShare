//
//  Share.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation
import FirebaseFirestore

struct Share: Codable {
    var shareId = String.empty
    var authorId = String.empty
    var title = String.empty
    var imageURL = String.empty
    var description = String.empty
    var meetTime = String.empty
    var meetPlace = String.empty
    var bestBefore = Timestamp()
    var dueDate = Timestamp()
    var postTime = Timestamp()
    var reports: [String] = []
}
