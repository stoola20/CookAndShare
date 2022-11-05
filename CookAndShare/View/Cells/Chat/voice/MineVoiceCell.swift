//
//  MineVoiceCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/5.
//

import UIKit

class MineVoiceCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var chatBubble: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatBubble.layer.cornerRadius = 15
    }

    func layoutCell(with message: Message) {
        timeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
    }
}
