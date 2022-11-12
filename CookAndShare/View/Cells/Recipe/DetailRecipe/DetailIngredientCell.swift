//
//  DetailIngredientCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

class DetailIngredientCell: UITableViewCell {

    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var ingredientQuantityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        ingredientNameLabel.textColor = UIColor.darkBrown
        ingredientQuantityLabel.textColor = UIColor.darkBrown
        ingredientNameLabel.font = UIFont.systemFont(ofSize: 18)
        ingredientQuantityLabel.font = UIFont.systemFont(ofSize: 18)
    }
    
    func layoutCell(with ingredient: Ingredient) {
        ingredientNameLabel.text = ingredient.name
        ingredientQuantityLabel.text = ingredient.quantity
    }
}
