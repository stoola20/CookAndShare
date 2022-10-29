//
//  NewRecipeDescriptionCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import UIKit

struct RecipeDescriptionInputModel {
    let name: String
    let description: String
    let duration: String
    let quantity: String
}

class NewRecipeDescriptionCell: UITableViewCell {
    
    private let duration: [Int] = [10, 20, 30, 45, 60, 90, 120, 180]
    private let quantity: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var completion: ((RecipeDescriptionInputModel) -> (Void))?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!

    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
            nameTextField.placeholder = Constant.recipeNameExample
        }
    }
    @IBOutlet weak var descriptionTextField: UITextField! {
        didSet {
            descriptionTextField.delegate = self
            descriptionTextField.placeholder = Constant.descriptionExample
        }
    }
    @IBOutlet weak var durationTextField: UITextField! {
        didSet {
            let durationPicker = UIPickerView()
            durationPicker.dataSource = self
            durationPicker.delegate = self
            durationPicker.tag = 1
            durationTextField.inputView = durationPicker
            durationTextField.delegate = self
        }
    }
    @IBOutlet weak var quantityTextField: UITextField! {
        didSet {
            let quantityPicker = UIPickerView()
            quantityPicker.dataSource = self
            quantityPicker.delegate = self
            quantityPicker.tag = 2
            quantityTextField.inputView = quantityPicker
            quantityTextField.delegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = Constant.recipeName
        descriptionLabel.text = Constant.description
        durationLabel.text = Constant.duration
        quantityLabel.text = Constant.quantity
    }
    
    func passData() {
        guard let name = nameTextField.text,
              let description = descriptionTextField.text,
              let duration = durationTextField.text,
              let quantity = quantityTextField.text
        else { return }
        
        let data = RecipeDescriptionInputModel(name: name, description: description, duration: duration, quantity: quantity)
        self.completion?(data)
    }
}

// MARK: - PickerView DataSource Delegate

extension NewRecipeDescriptionCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView.tag == 1 ? duration.count : quantity.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView.tag == 1 ? "\(duration[row]) 分鐘" : "\(quantity[row]) 人份"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            durationTextField.text = String(duration[row])
        } else {
            quantityTextField.text = String(quantity[row])
        }
    }
}

// MARK: - TextField Delegate
extension NewRecipeDescriptionCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        passData()
    }
}
