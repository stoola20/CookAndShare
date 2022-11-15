//
//  ProfileUserCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit
protocol ProfileUserCellDelegate: AnyObject {
    func willChangePhoto()
    func willEditName()
}

class ProfileUserCell: UITableViewCell {
    weak var delegate: ProfileUserCellDelegate!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editNameButton: UIButton!
    @IBOutlet weak var changePhotoButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        editNameButton.addTarget(self, action: #selector(editName), for: .touchUpInside)
        changePhotoButton.addTarget(self, action: #selector(choosePhoto), for: .touchUpInside)
    }

    func setUpUI() {
        profileImageView.applyshadowWithCorner(containerView: containerView, cornerRadious: profileImageView.bounds.width / 2)
        profileImageView.contentMode = .scaleAspectFill
        userName.textColor = UIColor.darkBrown
        userName.font = UIFont.boldSystemFont(ofSize: 20)
        editNameButton.tintColor = UIColor.myGreen
        changePhotoButton.layer.cornerRadius = 20
        changePhotoButton.layer.borderColor = UIColor.white.cgColor
        changePhotoButton.layer.borderWidth = 3
        changePhotoButton.contentMode = .scaleAspectFill
        changePhotoButton.tintColor = UIColor.myGreen
        changePhotoButton.backgroundColor = UIColor.white
    }

    func layoutCell(with user: User) {
        userName.text = user.name
        profileImageView.loadImage(user.imageURL, placeHolder: UIImage(named: Constant.chefMan))
    }

    @objc func choosePhoto() {
        delegate.willChangePhoto()
    }

    @objc func editName() {
        delegate.willEditName()
    }
}
