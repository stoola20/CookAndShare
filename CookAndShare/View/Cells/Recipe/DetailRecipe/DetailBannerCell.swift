//
//  DetailBannerCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit
import FirebaseFirestore

protocol DetailBannerCellDelegate: AnyObject {
    func goToProfile(_ userId: String)
}

class DetailBannerCell: UITableViewCell {
    let firestoreManager = FirestoreManager.shared
    var userId = String.empty
    weak var delegate: DetailBannerCellDelegate!
    @IBOutlet weak var mainImageVIew: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var storyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        mainImageVIew.contentMode = .scaleAspectFill
        print(#function)
        profileImage.isUserInteractionEnabled = true
        authorLabel.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(setGestureRecognizer())
        authorLabel.addGestureRecognizer(setGestureRecognizer())
    }

    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
        return tapRecognizer
    }
    
    @objc func goToProfile() {
        delegate.goToProfile(userId)
    }

    func layoutCell(with recipe: Recipe) {
        userId = recipe.authorId
        firestoreManager.fetchUserData(userId: recipe.authorId) { result in
            switch result {
            case .success(let user):
                self.profileImage.load(url: URL(string: user.imageURL)!)
                self.authorLabel.text = user.name
            case .failure(let error):
                print(error)
            }
        }
        mainImageVIew.load(url: URL(string: recipe.mainImageURL)!)
        titleLabel.text = recipe.title
        durationLabel.text = "⌛️ \(recipe.cookDuration) 分鐘"
        authorLabel.text = recipe.authorId
        storyLabel.text = recipe.description
    }
}
