//
//  ProfileUserCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit

class ProfileUserCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editNameButton: UIButton!
    @IBOutlet weak var changePhotoImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        profileImageView.applyshadowWithCorner(containerView: containerView, cornerRadious: profileImageView.bounds.width / 2)
        profileImageView.contentMode = .scaleAspectFill
        userName.textColor = UIColor.darkBrown
        userName.font = UIFont.boldSystemFont(ofSize: 20)
        editNameButton.tintColor = UIColor.myGreen
        editNameButton.layer.opacity = 0.8
        changePhotoImage.layer.cornerRadius = 20
        changePhotoImage.layer.borderColor = UIColor.white.cgColor
        changePhotoImage.layer.borderWidth = 3
        changePhotoImage.contentMode = .scaleAspectFill
        changePhotoImage.tintColor = UIColor.myGreen
        changePhotoImage.backgroundColor = UIColor.white
    }

    func layoutCell(with user: User) {
        userName.text = user.name
        profileImageView.loadImage(user.imageURL, placeHolder: UIImage(named: Constant.chefMan))
    }
}
