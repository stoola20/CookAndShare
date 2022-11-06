//
//  PublicProfileHeaderCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit

protocol PublicProfileHeaderCellDelegate: AnyObject {
    func presentChatRoom()
}

class PublicProfileHeaderCell: UICollectionViewCell {
    weak var delegate: PublicProfileHeaderCellDelegate!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 50
        sendMessageButton.addTarget(self, action: #selector(presentChatRoom), for: .touchUpInside)
    }

    func layoutCell(with user: User) {
        userImageView.load(url: URL(string: user.imageURL)!)
        userNameLabel.text = user.name
    }

    @objc func presentChatRoom() {
        delegate.presentChatRoom()
    }
}
