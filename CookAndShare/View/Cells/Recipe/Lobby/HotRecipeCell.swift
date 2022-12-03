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
    var listener: ListenerRegistration?
    var hasSaved = false
    var recipeId = String.empty
    let firestoreManager = FirestoreManager.shared

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        setUpUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        listener?.remove()
    }

    func setUpUI() {
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

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
    }

    func layoutCell(with recipe: Recipe) {
        imageView.loadImage(recipe.mainImageURL, placeHolder: UIImage(named: Constant.friedRice))
        titleLabel.text = recipe.title
        durationLabel.text = "⌛️ \(recipe.cookDuration) 分鐘"
        recipeId = recipe.recipeId

        listener = Firestore.firestore()
            .collection(Constant.firestoreRecipes)
            .document(recipeId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
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

    func updateButton() {
        let buttonImage = hasSaved
        ? UIImage(systemName: "bookmark.fill")
        : UIImage(systemName: "bookmark")
        storeButton.setImage(buttonImage, for: .normal)
    }

    @IBAction func storeRecipe(_ sender: UIButton) {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                    as? LoginViewController
            else { fatalError("Could not create loginVC") }
            loginVC.isPresented = true
            viewController?.present(loginVC, animated: true)
        } else {
            if !hasSaved {
                let alertView = SPAlertView(message: "收藏成功")
                alertView.duration = 0.8
                alertView.present()
            }
            firestoreManager.updateRecipeSaves(recipeId: recipeId, userId: Constant.getUserId(), hasSaved: hasSaved)
            firestoreManager.updateUserSaves(recipeId: recipeId, userId: Constant.getUserId(), hasSaved: hasSaved)
            hasSaved.toggle()
            updateButton()
        }
    }
}
