//
//  HotRecipeCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SPAlert

class HotRecipeCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!

    weak var viewController: UIViewController?
    private var listener: ListenerRegistration?
    private var hasSaved = false
    private var recipeId = String.empty
    private let firestoreManager = FirestoreManager.shared

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        listener?.remove()
    }

    func layoutCell(with recipe: Recipe) {
        config(recipe)
        self.recipeId = recipe.recipeId
        listenTo(recipe: recipe)
    }

    // MARK: - Private methods
    private func setUpUI() {
        storeButton.tintColor = UIColor.background
        heartImageView.tintColor = UIColor.background
        likesLabel.textColor = UIColor.background
        likesLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.darkBrown
        durationLabel.textColor = UIColor.darkBrown

        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 1, height: 3)
        containerView.layer.shadowRadius = 2
        containerView.layer.cornerRadius = 10

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
    }

    private func config(_ recipe: Recipe) {
        imageView.loadImage(recipe.mainImageURL, placeHolder: UIImage(named: Constant.friedRice))
        titleLabel.text = recipe.title
        durationLabel.text = "⌛️ \(recipe.cookDuration) 分鐘"
    }

    private func listenTo(recipe: Recipe) {
        let docRef = FirestoreEndpoint.recipes.collectionRef.document(recipe.recipeId)
        listener = docRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self else { return }
            guard let document = documentSnapshot else {
                print("Error fetching document: \(String(describing: error))")
                return
            }

            guard let newRecipe = try? document.data(as: Recipe.self) else {
                print("Document data was empty.")
                return
            }

            self.likesLabel.text = String(recipe.likes.count)
            self.hasSaved = newRecipe.saves.contains(Constant.getUserId())
            self.updateButton()
        }
    }

    private func updateButton() {
        let buttonImage = hasSaved
        ? UIImage(systemName: "bookmark.fill")
        : UIImage(systemName: "bookmark")
        storeButton.setImage(buttonImage, for: .normal)
    }

    private func showSignInVC() {
        let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: LoginViewController.self)
        ) as? LoginViewController
        else { fatalError("Could not create loginVC") }
        loginVC.isPresented = true
        viewController?.present(loginVC, animated: true)
    }

    private func updateFirestore() {
        let recipeRef = FirestoreEndpoint.recipes.collectionRef.document(recipeId)
        let userRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())

        if hasSaved {
            firestoreManager.arrayRemoveString(
                docRef: recipeRef,
                field: Constant.saves,
                value: Constant.getUserId()
            )
            firestoreManager.arrayRemoveString(
                docRef: userRef,
                field: Constant.savedRecipesId,
                value: recipeId
            )
        } else {
            let alertView = AlertAppleMusic17View(title: "收藏成功", subtitle: nil, icon: nil)
            alertView.duration = 0.8
            alertView.present(on: self.contentView)
            firestoreManager.arrayUnionString(
                docRef: recipeRef,
                field: Constant.saves,
                value: Constant.getUserId()
            )
            firestoreManager.arrayUnionString(
                docRef: userRef,
                field: Constant.savedRecipesId,
                value: recipeId
            )
        }
        hasSaved.toggle()
    }

    // MARK: - Action
    @IBAction func storeRecipe(_ sender: UIButton) {
        if Auth.auth().currentUser == nil {
            showSignInVC()
        } else {
            updateFirestore()
            updateButton()
        }
    }
}
