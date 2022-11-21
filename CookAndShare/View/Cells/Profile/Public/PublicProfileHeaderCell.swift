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
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        sendMessageButton.addTarget(self, action: #selector(presentChatRoom), for: .touchUpInside)
    }

    func setUpUI() {
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 50
        userImageView.layer.borderWidth = 3
        userImageView.layer.borderColor = UIColor.white.cgColor

        userNameLabel.textColor = UIColor.darkBrown
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 20)

        sendMessageButton.backgroundColor = UIColor.lightOrange
        sendMessageButton.layer.cornerRadius = 5
        sendMessageButton.tintColor = UIColor.darkBrown
        sendMessageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)

        blockUserButton.backgroundColor = UIColor.lightOrange
        blockUserButton.layer.cornerRadius = 5
        blockUserButton.tintColor = UIColor.darkBrown
        blockUserButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }

    func layoutCell(with user: User) {
        userImageView.loadImage(user.imageURL, placeHolder: UIImage(named: Constant.chefMan))
        userNameLabel.text = user.name
        if user.id == Constant.getUserId() {
            sendMessageButton.isHidden = true
            blockUserButton.isHidden = true
        }
    }

    @objc func presentChatRoom() {
        delegate.presentChatRoom()
    }
}
