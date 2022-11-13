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
    var duration: Double
//    let status: Bool
}

enum ContentType: String {
    case text
    case image
    case voice
    case location

    func getMessageBody() -> String {
        switch self {
        case .text:
            return "向您傳送了文字訊息"
        case .image:
            return "向您傳送了照片"
        case .voice:
            return "向您傳送了語音訊息"
        case .location:
            return "向您傳送了位置訊息"
        }
    }
}
