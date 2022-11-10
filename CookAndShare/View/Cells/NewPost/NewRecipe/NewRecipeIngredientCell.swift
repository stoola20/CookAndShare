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
    func addIngredient()
}

class NewRecipeIngredientCell: UITableViewCell {
    weak var delegate: NewRecipeIngredientDelegate!

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
            nameTextField.placeholder = Constant.ingredientName
            nameTextField.returnKeyType = .next
        }
    }
    @IBOutlet weak var quantityTextField: UITextField! {
        didSet {
            quantityTextField.delegate = self
            quantityTextField.placeholder = Constant.ingredientQuantity
            quantityTextField.returnKeyType = .done
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        deleteButton.isHidden = true
        deleteButton.tintColor = UIColor.darkBrown
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        deleteButton.isHidden = true
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
            delegate.addIngredient()
            deleteButton.isHidden = false
        }
    }
}

// MARK: - TextField Delegate
extension NewRecipeIngredientCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            quantityTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField != quantityTextField { return }
        passData()
    }
}
