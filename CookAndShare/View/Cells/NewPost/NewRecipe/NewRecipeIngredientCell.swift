//
//  NewRecipeIngredientCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import UIKit

protocol NewRecipeIngredientDelegate: AnyObject {
    func didDelete(_ cell: NewRecipeIngredientCell, _ ingredient: Ingredient)
    func didAddIngredient(_ cell: NewRecipeIngredientCell, _ ingredient: Ingredient)
}

class NewRecipeIngredientCell: UITableViewCell {
    
    weak var delegate: NewRecipeIngredientDelegate!

    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
            nameTextField.placeholder = Constant.ingredientName
        }
    }
    @IBOutlet weak var quantityTextField: UITextField! {
        didSet {
            quantityTextField.delegate = self
            quantityTextField.placeholder = Constant.ingredientQuantity
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        nameTextField.text = String.empty
        quantityTextField.text = String.empty
    }
    
    @IBAction func deleteIngredient(_ sender: UIButton) {
        guard let ingredientName = nameTextField.text,
              let ingredientQuantity = quantityTextField.text
        else { return }
        delegate.didDelete(self, Ingredient(name: ingredientName, quantity: ingredientQuantity))
    }
    
    func passData() {
        guard let ingredientName = nameTextField.text,
              let ingredientQuantity = quantityTextField.text
        else { return }
        if ingredientName.isEmpty {
            nameTextField.placeholder = "請輸入食材名稱！"
        } else if ingredientQuantity.isEmpty {
            quantityTextField.placeholder = "請輸入份量！"
        } else {
            let ingredient = Ingredient(name: ingredientName, quantity: ingredientQuantity)
            delegate.didAddIngredient(self, ingredient)
        }
    }
}

// MARK: - TextField Delegate
extension NewRecipeIngredientCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField != quantityTextField { return }
        passData()
    }
}
