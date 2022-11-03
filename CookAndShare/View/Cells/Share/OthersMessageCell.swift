//
//  OthersMessageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit

class OthersMessageCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var imageTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func layoutCell(with message: Message) {
        switch message.contentType {
        case "text":
            messageLabel.text = message.content
            messageLabel.isHidden = false
            timeLabel.isHidden = false
            imageTimeLabel.isHidden = true
            largeImageView.isHidden = true
        case "image":
            largeImageView.load(url: URL(string: message.content)!)
            messageLabel.isHidden = true
            timeLabel.isHidden = true
            imageTimeLabel.isHidden = false
            largeImageView.isHidden = false
        case "voice":
            messageLabel.isHidden = true
            timeLabel.isHidden = true
            imageTimeLabel.isHidden = true
            largeImageView.isHidden = true
        default:
            messageLabel.isHidden = true
            timeLabel.isHidden = true
            imageTimeLabel.isHidden = true
            largeImageView.isHidden = true
        }
    }
}
