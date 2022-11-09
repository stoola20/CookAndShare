//
//  ShoppingListCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit

class ShoppingListCell: UITableViewCell {
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    var itemIsSelected = true
    var isInShoppingList = false {
        didSet {
            if isInShoppingList {
                checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
            } else {
                checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            }
        }
    }
    var deleteCompletion: ((Int) -> Void)?
    var addCompletion: ((ShoppingListCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        itemIsSelected = isInShoppingList ? false : true
        setUpUI()
    }

    func setUpUI() {
        nameLabel.textColor = UIColor.darkBrown
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        checkButton.tintColor = UIColor.myGreen
    }

    func layoutCell(with ingredient: Ingredient) {
        nameLabel.text = ingredient.name
        quantityLabel.text = ingredient.quantity
        isInShoppingList = false
    }

    func layoutCell(with item: ShoppingList) {
        nameLabel.text = item.name
        quantityLabel.text = item.quantity
        isInShoppingList = true
    }

    @IBAction func toggleItem(_ sender: UIButton) {
        if itemIsSelected {
            checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
            if !isInShoppingList { deleteCompletion?(checkButton.tag) }
        } else {
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            if !isInShoppingList { addCompletion?(self) }
        }
        itemIsSelected.toggle()
    }
}
