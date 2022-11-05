//
//  ChatListCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit

class ChatListCell: UITableViewCell {
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func layoutCell(with friendName: String, imageURL: String, lastMessage: Message) {
        friendNameLabel.text = friendName
        friendImageView.load(url: URL(string: imageURL)!)

        switch lastMessage.contentType {
        case Constant.text:
            lastMessageLabel.text = lastMessage.content
        case Constant.image:
            lastMessageLabel.text = lastMessage.senderId == Constant.userId ? "您傳送了一張照片" : "\(friendName)傳送了一張照片給您"
        case Constant.location:
            lastMessageLabel.text = lastMessage.senderId == Constant.userId ? "您傳送了位置訊息" : "\(friendName)傳送了位置訊息"
        default:
            lastMessageLabel.text = lastMessage.senderId == Constant.userId ? "您傳送了一則語音" : "\(friendName)傳送了一則語音"
        }
        lastTimeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(lastMessage.time.seconds)))
    }
}
