//
//  OthersMessageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit
import GoogleMaps

class OthersMessageCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var chatBubble: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        chatBubble.layer.cornerRadius = 15
        friendImageView.layer.cornerRadius = 20
        friendImageView.contentMode = .scaleAspectFill
        friendImageView.clipsToBounds = true
    }

    func layoutCell(with message: Message, friendImageURL: String) {
        friendImageView.load(url: URL(string: friendImageURL)!)
        messageLabel.text = message.content
        timeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
    }
}
