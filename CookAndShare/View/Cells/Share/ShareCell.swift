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
}

class ShareCell: UITableViewCell {
    let firestoreManager = FirestoreManager.shared
    var userId = String.empty
    var foodImageURL = ""
    weak var delegate: ShareCellDelegate!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bestBeforeLabel: UILabel!
    @IBOutlet weak var meetTimeLabel: UILabel!
    @IBOutlet weak var meetPlaceLabel: UILabel!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var seeProfileButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(setGestureRecognizer())
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(setGestureRecognizer())
        seeProfileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
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
        postTimeLabel.font = UIFont.systemFont(ofSize: 15)
        postTimeLabel.textColor = UIColor.systemBrown
        titleLabel.textColor = UIColor.darkBrown
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        descriptionLabel.textColor = UIColor.darkBrown
        bestBeforeLabel.textColor = UIColor.darkBrown

        meetTimeLabel.textColor = UIColor.darkBrown
        meetTimeLabel.font = UIFont.systemFont(ofSize: 16)
        meetPlaceLabel.textColor = UIColor.darkBrown
        meetPlaceLabel.font = UIFont.systemFont(ofSize: 16)
        seeProfileButton.tintColor = .darkBrown
        seeProfileButton.layer.cornerRadius = 15
        seeProfileButton.backgroundColor = .lightOrange
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

    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = UIImage(named: Constant.chefMan)
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
        let timeInterval = Date() - Date(timeIntervalSince1970: Double(share.postTime.seconds))
        postTimeLabel.text = timeInterval.convertToString(from: timeInterval)
        titleLabel.text = "\(share.title)"
        descriptionLabel.text = "\(share.description)"
        bestBeforeLabel.text = "\(Date.dateFormatter.string(from: Date(timeIntervalSince1970: Double(share.bestBefore.seconds))))"
        meetTimeLabel.text = "\(share.meetTime)"
        meetPlaceLabel.text = "\(share.meetPlace)"
        foodImageView.loadImage(share.imageURL, placeHolder: UIImage(named: Constant.friedRice))
        foodImageURL = share.imageURL
    }
}
