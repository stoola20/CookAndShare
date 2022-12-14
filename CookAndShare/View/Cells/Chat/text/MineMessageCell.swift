//
//  MineMessageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit
import GoogleMaps

class MineMessageCell: UITableViewCell, MessageCell {
    @IBOutlet weak var chatBubble: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        chatBubble.layer.cornerRadius = 15
        chatBubble.backgroundColor = UIColor.lightOrange
        messageLabel.textColor = UIColor.darkBrown
        timeLabel.textColor = UIColor.systemBrown
        timeLabel.font = UIFont.systemFont(ofSize: 13)
    }

    func layoutCell(with message: Message, friendImageURL: String, viewController: ChatRoomViewController, heroId: String) {
        messageLabel.text = message.content
        timeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
    }
}
