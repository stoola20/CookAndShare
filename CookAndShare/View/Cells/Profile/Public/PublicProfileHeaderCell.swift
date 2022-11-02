//
//  PublicProfileHeaderCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit

class PublicProfileHeaderCell: UICollectionViewCell {

    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 50
    }

    func layoutCell(with user: User) {
        userImageView.load(url: URL(string: user.imageURL)!)
        userNameLabel.text = user.name
    }
}
