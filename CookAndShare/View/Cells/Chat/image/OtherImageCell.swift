//
//  OtherImageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/5.
//

import UIKit

class OtherImageCell: UITableViewCell {
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var imageTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        largeImageView.layer.cornerRadius = 20
        friendImageView.layer.cornerRadius = 20
        largeImageView.contentMode = .scaleAspectFill
        friendImageView.contentMode = .scaleAspectFill
        imageTimeLabel.textColor = UIColor.systemBrown
        imageTimeLabel.font = UIFont.systemFont(ofSize: 13)
    }

    func layoutCell(with message: Message, friendImageURL: String) {
        friendImageView.load(url: URL(string: friendImageURL)!)

        largeImageView.load(url: URL(string: message.content)!)
        imageTimeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds))) 
    }
}
