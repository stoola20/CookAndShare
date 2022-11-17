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
        setUpUI()
    }

    func setUpUI() {
        friendImageView.layer.cornerRadius = 30
        friendImageView.contentMode = .scaleAspectFill
        friendNameLabel.textColor = UIColor.darkBrown
        lastMessageLabel.textColor = UIColor.systemBrown
        lastTimeLabel.textColor = UIColor.systemBrown
        friendNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        lastTimeLabel.font = UIFont.systemFont(ofSize: 15)
    }

    func layoutCell(with friendName: String, imageURL: String, lastMessage: Message) {
        friendNameLabel.text = friendName
        friendImageView.loadImage(imageURL, placeHolder: UIImage(named: Constant.chefMan))

        switch lastMessage.contentType {
        case Constant.text:
            lastMessageLabel.text = lastMessage.content
        case Constant.image:
            lastMessageLabel.text = lastMessage.senderId == Constant.getUserId() ? "您傳送了一張照片" : "\(friendName)傳送了一張照片給您"
        case Constant.location:
            lastMessageLabel.text = lastMessage.senderId == Constant.getUserId() ? "您傳送了位置訊息" : "\(friendName)向您傳送了位置訊息"
        default:
            lastMessageLabel.text = lastMessage.senderId == Constant.getUserId() ? "您傳送了一則語音" : "\(friendName)向您傳送了一則語音"
        }
        lastTimeLabel.text = Date.getChatRoomTimeString(from: Date(timeIntervalSince1970: Double(lastMessage.time.seconds)))
    }
}
