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
//            itemIsSelected = isInShoppingList ? false : true
//            if !isInShoppingList {
//                checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
//            }
        }
    }
    var deleteCompletion: ((Int) -> Void)?
    var addCompletion: ((ShoppingListCell) -> Void)?
    let coreDataManager = CoreDataManager.shared

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        nameLabel.textColor = UIColor.darkBrown
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        quantityLabel.textColor = UIColor.darkBrown
        quantityLabel.font = UIFont.systemFont(ofSize: 20)
        checkButton.tintColor = UIColor.myGreen
    }

    func layoutCell(with ingredient: Ingredient) {
        nameLabel.text = ingredient.name
        quantityLabel.text = ingredient.quantity
        isInShoppingList = false
        checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
    }

    func layoutCell(with item: ShoppingList) {
        nameLabel.text = item.name
        quantityLabel.text = item.quantity
        isInShoppingList = true
        self.itemIsSelected = item.done
        if item.done {
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
    }

    @IBAction func toggleItem(_ sender: UIButton) {
        guard
            let name = nameLabel.text,
            let quantity = quantityLabel.text
        else { return }

        if itemIsSelected {
            checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
            if isInShoppingList {
                coreDataManager.updateItem(name: name, quantity: quantity, done: false)
            } else {
                deleteCompletion?(checkButton.tag)
            }
        } else {
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            if isInShoppingList {
                coreDataManager.updateItem(name: name, quantity: quantity, done: true)
            } else {
                addCompletion?(self)
            }
        }
        itemIsSelected.toggle()
    }
}
