//
//  HotRecipeCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

class HotRecipeCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    var hasSaved = false
    var recipeId = String.empty
    let firestoreManager = FirestoreManager.shared

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
    }

    func layoutCell(with recipe: Recipe) {
        guard let url = URL(string: recipe.mainImageURL) else { return }
        imageView.load(url: url)
        likesLabel.text = String(recipe.likes.count)
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

    @IBAction func storeRecipe(_ sender: UIButton) {
        firestoreManager.updateRecipeSaves(recipeId: recipeId, userId: Constant.userId, hasSaved: hasSaved)
        firestoreManager.updateUserSaves(recipeId: recipeId, userId: Constant.userId, hasSaved: hasSaved)
        hasSaved.toggle()
        updateButton()
    }
}