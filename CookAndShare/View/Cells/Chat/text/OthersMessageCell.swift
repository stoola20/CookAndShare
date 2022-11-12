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
        setUpUI()
    }

    func setUpUI() {
        chatBubble.layer.cornerRadius = 15
        chatBubble.backgroundColor = UIColor.myGreen
        friendImageView.layer.cornerRadius = 20
        friendImageView.contentMode = .scaleAspectFill
        timeLabel.textColor = UIColor.systemBrown
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.textColor = UIColor.background
    }

    func layoutCell(with message: Message, friendImageURL: String) {
        friendImageView.loadImage(friendImageURL, placeHolder: UIImage(named: Constant.chefMan))
        messageLabel.text = message.content
        timeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
    }
}
