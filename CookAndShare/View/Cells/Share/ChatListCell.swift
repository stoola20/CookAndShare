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

    func layoutCell(with friendName: String, imageURL: String, lastMessage: String, lastTime: String) {
        friendNameLabel.text = friendName
        friendImageView.load(url: URL(string: imageURL)!)
        lastMessageLabel.text = lastMessage
        lastTimeLabel.text = lastTime
    }
}
