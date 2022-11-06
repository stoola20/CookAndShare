//
//  MineMessageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit
import GoogleMaps

class MineMessageCell: UITableViewCell {
    @IBOutlet weak var chatBubble: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        chatBubble.layer.cornerRadius = 15
    }

    func layoutCell(with message: Message) {
        messageLabel.text = message.content
        timeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
    }
}
