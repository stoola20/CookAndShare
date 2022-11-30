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
    func deletePost()
    func editPost()
    func block(user: User)
    func reportRecipe()
}

class DetailBannerCell: UITableViewCell {
    let firestoreManager = FirestoreManager.shared
    var user: User?

    weak var delegate: DetailBannerCellDelegate!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var seeProfileButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        setUpUI()
        profileImage.isUserInteractionEnabled = true
        authorLabel.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(setGestureRecognizer())
        authorLabel.addGestureRecognizer(setGestureRecognizer())
        seeProfileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        moreButton.showsMenuAsPrimaryAction = true
    }

    func setUpUI() {
        profileImage.layer.cornerRadius = 20
        profileImage.contentMode = .scaleAspectFill
        containerView.layer.cornerRadius = 30
        titleLabel.textColor = UIColor.darkBrown
        durationLabel.textColor = UIColor.darkBrown
        authorLabel.textColor = UIColor.darkBrown
        authorLabel.font = UIFont.boldSystemFont(ofSize: 19)
        storyLabel.textColor = UIColor.darkBrown
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
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
        guard let user = user else {
            return
        }
        delegate.goToProfile(user.id)
    }

    @objc func editPost() {
        delegate.editPost()
    }

    @objc func deletePost() {
        delegate.deletePost()
    }

    @objc func blockList() {
        guard let user = user else {
            return
        }
        delegate.block(user: user)
    }

    @objc func report() {
        delegate.reportRecipe()
    }

    func layoutCell(with recipe: Recipe) {
        firestoreManager.fetchUserData(userId: recipe.authorId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.profileImage.loadImage(user.imageURL, placeHolder: UIImage(named: Constant.chefMan))
                self.authorLabel.text = user.name
                self.user = user
            case .failure(let error):
                print(error)
            }
        }
        titleLabel.text = recipe.title
        durationLabel.text = "⌛️ 烹調時間： \(recipe.cookDuration) 分鐘"
        authorLabel.text = recipe.authorId
        storyLabel.text = recipe.description

        if recipe.authorId == Constant.getUserId() {
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
        } else if !Constant.getUserId().isEmpty {
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
        } else {
            moreButton.menu = UIMenu(children: [
                UICommand(
                    title: "檢舉",
                    image: UIImage(systemName: "exclamationmark.bubble"),
                    action: #selector(report),
                    attributes: .destructive
                )
            ])
        }

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
