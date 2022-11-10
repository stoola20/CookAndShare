//
//  MineImageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/5.
//

import UIKit

class MineImageCell: UITableViewCell {
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var imageTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        largeImageView.layer.cornerRadius = 20
        largeImageView.contentMode = .scaleAspectFill
        imageTimeLabel.textColor = UIColor.systemBrown
        imageTimeLabel.font = UIFont.systemFont(ofSize: 13)
    }

    func layoutCell(with message: Message) {
        largeImageView.load(url: URL(string: message.content)!)
        imageTimeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
    }
}
