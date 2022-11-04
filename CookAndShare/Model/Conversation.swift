//
//  Conversation.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct Conversation: Codable {
    var channelId = String.empty
    var friendIds: [String] = []
    var messages: [Message] = []
//    let lastReadTime: Timestamp
}

struct Message: Codable {
    var senderId: String
    var contentType: String
    var content: String
    var time: Timestamp
//    let status: Bool
}

enum ContentType: String {
    case text
    case image
    case voice
    case location
}
