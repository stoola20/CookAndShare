//
//  AllRecipeCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit
import FirebaseAuth

class AllRecipeCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var yellowBackground: UIView!

    weak var viewController: UIViewController?
    let firestoreManager = FirestoreManager.shared
    var hasSaved = false
    var recipeId = String.empty
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        imageView.contentMode = .scaleAspectFill
        titleLabel.textColor = UIColor.darkBrown
        durationLabel.textColor = UIColor.darkBrown
        yellowBackground.layer.cornerRadius = 20
        storeButton.tintColor = UIColor.darkBrown
        imageView.applyshadowWithCorner(containerView: containerView, cornerRadious: 50)
    }

    func layoutCell(with recipe: Recipe) {
        imageView.loadImage(recipe.mainImageURL, placeHolder: UIImage(named: Constant.friedRice))
        titleLabel.text = recipe.title
        durationLabel.text = "⌛️ \(recipe.cookDuration) 分鐘"
        hasSaved = recipe.saves.contains(Constant.getUserId())
        recipeId = recipe.recipeId
        updateButton()
    }

    func updateButton() {
        let buttonImage = hasSaved
        ? UIImage(systemName: "bookmark.fill")
        : UIImage(systemName: "bookmark")
        storeButton.setImage(buttonImage, for: .normal)
    }

    @IBAction func storeRecipe(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                    as? LoginViewController
            else { fatalError("Could not create loginVC") }
            viewController?.present(loginVC, animated: true)
        } else {
            firestoreManager.updateRecipeSaves(recipeId: recipeId, userId: Constant.getUserId(), hasSaved: hasSaved)
            firestoreManager.updateUserSaves(recipeId: recipeId, userId: Constant.getUserId(), hasSaved: hasSaved)
            hasSaved.toggle()
            updateButton()
        }
    }
}
