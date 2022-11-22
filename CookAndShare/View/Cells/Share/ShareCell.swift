//
//  ShareCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit
import Hero

protocol ShareCellDelegate: AnyObject {
    func goToProfile(_ userId: String)
    func presentLargePhoto(url: String, heroId: String)
    func deletePost(_ cell: ShareCell)
    func editPost(_ cell: ShareCell)
}

class ShareCell: UITableViewCell {
    let firestoreManager = FirestoreManager.shared
    var userId = String.empty
    var foodImageURL = ""
    weak var delegate: ShareCellDelegate!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bestBeforeLabel: UILabel!
    @IBOutlet weak var meetTimeLabel: UILabel!
    @IBOutlet weak var meetPlaceLabel: UILabel!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var seeProfileButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(setGestureRecognizer())
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(setGestureRecognizer())
        moreButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        let foodImageGesture = UITapGestureRecognizer(target: self, action: #selector(presentPhoto))
        foodImageView.isUserInteractionEnabled = true
        foodImageView.addGestureRecognizer(foodImageGesture)
        setUpUI()
    }

    func setUpUI() {
        foodImageView.contentMode = .scaleAspectFill
        foodImageView.layer.cornerRadius = 15
        foodImageView.layer.borderWidth = 1
        foodImageView.layer.borderColor = UIColor.lightOrange?.cgColor
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 30

        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        userNameLabel.textColor = UIColor.darkBrown
        titleLabel.textColor = UIColor.darkBrown
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        descriptionLabel.textColor = UIColor.darkBrown
        bestBeforeLabel.textColor = UIColor.darkBrown

        meetTimeLabel.textColor = UIColor.darkBrown
        meetTimeLabel.font = UIFont.systemFont(ofSize: 16)
        meetPlaceLabel.textColor = UIColor.darkBrown
        meetPlaceLabel.font = UIFont.systemFont(ofSize: 16)
        moreButton.tintColor = .darkBrown
        moreButton.showsMenuAsPrimaryAction = true
        seeProfileButton.tintColor = .darkBrown
        seeProfileButton.layer.cornerRadius = 15
        seeProfileButton.backgroundColor = .lightOrange
        seeProfileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
    }

    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
        return tapRecognizer
    }

    @objc func goToProfile() {
        delegate.goToProfile(userId)
    }

    @objc func presentPhoto() {
        delegate.presentLargePhoto(url: foodImageURL, heroId: foodImageView.heroID ?? "")
    }

    @objc func editPost() {
        print("編輯貼文")
        delegate.editPost(self)
    }

    @objc func deletePost() {
        delegate.deletePost(self)
    }

    @objc func blockList() {
        print("封鎖用戶")
    }

    @objc func report() {
        print("檢舉")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = UIImage(named: Constant.chefMan)
        userNameLabel.text = ""
    }

    func layoutCell(with share: Share) {
        userId = share.authorId
        firestoreManager.fetchUserData(userId: share.authorId) { result in
            switch result {
            case .success(let user):
                self.userImageView.loadImage(user.imageURL, placeHolder: UIImage(named: Constant.chefMan))
                self.userNameLabel.text = user.name
            case .failure(let error):
                print(error)
            }
        }
        titleLabel.text = "\(share.title)"
        descriptionLabel.text = "\(share.description)"
        bestBeforeLabel.text = "\(Date.dateFormatter.string(from: Date(timeIntervalSince1970: Double(share.bestBefore.seconds))))"
        meetTimeLabel.text = "\(share.meetTime)"
        meetPlaceLabel.text = "\(share.meetPlace)"
        foodImageView.loadImage(share.imageURL, placeHolder: UIImage(named: Constant.friedRice))
        foodImageURL = share.imageURL

        if share.authorId == Constant.getUserId() {
            seeProfileButton.isHidden = true
            moreButton.menu = UIMenu(children: [
                UICommand(
                    title: "編輯貼文",
                    image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"),
                    action: #selector(editPost)
                ),
                UICommand(
                    title: "刪除貼文",
                    image: UIImage(systemName: "trash"),
                    action: #selector(deletePost),
                    attributes: .destructive
                )
            ])
        } else {
            seeProfileButton.isHidden = false
            moreButton.menu = UIMenu(children: [
                UICommand(
                    title: "檢舉",
                    image: UIImage(systemName: "exclamationmark.bubble"),
                    action: #selector(report),
                    attributes: .destructive
                ),
                UICommand(
                    title: "封鎖用戶",
                    image: UIImage(systemName: "hand.raised.slash"),
                    action: #selector(blockList),
                    attributes: .destructive
                )
            ])
        }
    }
}
