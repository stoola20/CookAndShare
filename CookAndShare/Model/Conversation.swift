//
//  Conversation.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation
import FirebaseFirestore

struct Conversation: Codable {
    let channelId: String
    let friendId: [String]
    let messages: [Message]
//    let lastReadTime: Timestamp
}

struct Message: Codable {
    let messageId: String
    let senderId: String
    let contentType: String
    let content: String
    let time: Timestamp
//    let status: Bool
}
