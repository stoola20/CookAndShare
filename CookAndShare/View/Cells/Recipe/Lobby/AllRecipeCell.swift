//
//  AllRecipeCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

class AllRecipeCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var yellowBackground: UIView!
    
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
        imageView.layer.cornerRadius = 50
    }

    func layoutCell(with recipe: Recipe) {
        guard let url = URL(string: recipe.mainImageURL) else { return }
        imageView.load(url: url)
        titleLabel.text = recipe.title
        durationLabel.text = "⌛️ \(recipe.cookDuration) 分鐘"
        hasSaved = recipe.saves.contains(Constant.userId)
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
        firestoreManager.updateRecipeSaves(recipeId: recipeId, userId: Constant.userId, hasSaved: hasSaved)
        firestoreManager.updateUserSaves(recipeId: recipeId, userId: Constant.userId, hasSaved: hasSaved)
        hasSaved.toggle()
        updateButton()
    }
}
