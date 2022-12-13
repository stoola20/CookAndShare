//
//  MessageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/12/11.
//

import UIKit

protocol MessageCell: UITableViewCell {
    func layoutCell(with message: Message, friendImageURL: String, viewController: ChatRoomViewController, heroId: String)
}

enum MessageType: String {
    case mineText = "mine text"
    case mineImage = "mine image"
    case mineLocation = "mine location"
    case mineVoice = "mine voice"
    case otherText = "other text"
    case otherImage = "other image"
    case otherLocation = "other location"
    case otherVoice = "other voice"

    var cellIdentifier: String {
        switch self {
        case .mineText:
            return MineMessageCell.identifier
        case .mineImage:
            return MineImageCell.identifier
        case .mineLocation:
            return MineLocationCell.identifier
        case .mineVoice:
            return MineVoiceCell.identifier
        case .otherText:
            return OthersMessageCell.identifier
        case .otherImage:
            return OtherImageCell.identifier
        case .otherLocation:
            return OtherLocationCell.identifier
        case .otherVoice:
            return OtherVoiceCell.identifier
        }
    }
}
