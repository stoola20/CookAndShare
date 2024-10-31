//
//  AllRecipeCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SPAlert

class AllRecipeCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var yellowBackground: UIView!

    weak var viewController: UIViewController?
    private let firestoreManager = FirestoreManager.shared
    private var listener: ListenerRegistration?
    private var hasSaved = false
    private var recipeId = String.empty

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
        recipeId = recipe.recipeId
        listenTo(recipe: recipe)
    }

    // MARK: - Private methods
    private func setUpUI() {
        imageView.contentMode = .scaleAspectFill
        titleLabel.textColor = UIColor.darkBrown
        durationLabel.textColor = UIColor.darkBrown
        yellowBackground.layer.cornerRadius = 20
        storeButton.tintColor = UIColor.darkBrown
        imageView.applyshadowWithCorner(containerView: containerView, cornerRadious: 50)
    }

    private func config(_ recipe: Recipe) {
        imageView.loadImage(recipe.mainImageURL, placeHolder: UIImage(named: Constant.friedRice))
        titleLabel.text = recipe.title
        durationLabel.text = "⌛️ \(recipe.cookDuration) 分鐘"
        hasSaved = recipe.saves.contains(Constant.getUserId())
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
    @IBAction func storeRecipe(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            showSignInVC()
        } else {
            updateFirestore()
            updateButton()
        }
    }
}
