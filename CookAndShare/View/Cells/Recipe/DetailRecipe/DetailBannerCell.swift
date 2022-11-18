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
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var seeProfileButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        profileImage.isUserInteractionEnabled = true
        authorLabel.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(setGestureRecognizer())
        authorLabel.addGestureRecognizer(setGestureRecognizer())
        seeProfileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
    }

    func setUpUI() {
        mainImageVIew.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 20
        profileImage.contentMode = .scaleAspectFill
        containerView.layer.cornerRadius = 35
        titleLabel.textColor = UIColor.darkBrown
        durationLabel.textColor = UIColor.darkBrown
        authorLabel.textColor = UIColor.darkBrown
        authorLabel.font = UIFont.boldSystemFont(ofSize: 20)
        postTimeLabel.textColor = UIColor.myOrange
        postTimeLabel.font = UIFont.systemFont(ofSize: 16)
        storyLabel.textColor = UIColor.darkBrown
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        likesLabel.textColor = UIColor.darkBrown
        likesLabel.font = UIFont.boldSystemFont(ofSize: 18)
        heartImageView.tintColor = UIColor.myOrange
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

    func layoutCell(with recipe: Recipe) {
        userId = recipe.authorId
        firestoreManager.fetchUserData(userId: recipe.authorId) { result in
            switch result {
            case .success(let user):
                self.profileImage.loadImage(user.imageURL, placeHolder: UIImage(named: Constant.chefMan))
                self.authorLabel.text = user.name
            case .failure(let error):
                print(error)
            }
        }
        mainImageVIew.loadImage(recipe.mainImageURL, placeHolder: UIImage(named: Constant.friedRice))
        titleLabel.text = recipe.title
        durationLabel.text = "⌛️ 烹調時間： \(recipe.cookDuration) 分鐘"
        authorLabel.text = recipe.authorId
        postTimeLabel.text = Date.getChatRoomTimeString(from: Date(timeIntervalSince1970: Double(recipe.time.seconds)))
        storyLabel.text = recipe.description


        Firestore.firestore().collection(Constant.firestoreRecipes).document(recipe.recipeId).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self else { return }
            guard let document = documentSnapshot else {
                print("Error fetching document: \(String(describing: error))")
                return
            }

            guard let newRecipe = try? document.data(as: Recipe.self) else {
                print("Document data was empty.")
                return
            }
            self.likesLabel.text = String(newRecipe.likes.count)
            if newRecipe.likes.isEmpty {
                self.heartImageView.image = UIImage(systemName: "heart")
            } else {
                self.heartImageView.image = UIImage(systemName: "heart.fill")
            }
        }
    }
}
