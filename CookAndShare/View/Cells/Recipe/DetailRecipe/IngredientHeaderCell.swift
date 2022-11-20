//
//  IngredientHeaderCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/20.
//

import UIKit

class IngredientHeaderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    weak var viewController: DetailRecipeViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        titleLabel.textColor = UIColor.darkBrown
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        quantityLabel.textColor = UIColor.myOrange
        quantityLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addButton.backgroundColor = UIColor.lightOrange
        addButton.layer.cornerRadius = 15
    }

    func layoutHeader(with recipe: Recipe) {
        quantityLabel.text = String(recipe.quantity)
    }

    @IBAction func addToList(_ sender: UIButton) {
        viewController?.willAddIngredient()
    }
}
