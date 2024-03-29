//
//  NewRecipeDescriptionCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import UIKit
import PhotosUI

struct RecipeDescriptionInputModel {
    var name = String.empty
    var description = String.empty
    var duration = String.empty
    var quantity = String.empty
}

protocol NewRecipeDescriptionDelegate: AnyObject {
    func willPickImage(_ cell: NewRecipeDescriptionCell)
}

class NewRecipeDescriptionCell: UITableViewCell {
    private let duration: [Int] = [10, 20, 30, 45, 60, 90, 120, 180]
    private let quantity: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    weak var delegate: NewRecipeDescriptionDelegate!
    var data = RecipeDescriptionInputModel()
    var completion: ((RecipeDescriptionInputModel) -> Void)?

    @IBOutlet weak var mainImageView: UIImageView!
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
            durationTextField.text = "10"
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
            quantityTextField.text = "1"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        nameLabel.text = Constant.recipeName
        descriptionLabel.text = Constant.description
        durationLabel.text = Constant.duration
        quantityLabel.text = Constant.quantity
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(setGestureRecognizer())
    }

    func setUpUI() {
        nameLabel.textColor = UIColor.darkBrown
        descriptionLabel.textColor = UIColor.darkBrown
        durationLabel.textColor = UIColor.darkBrown
        quantityLabel.textColor = UIColor.darkBrown
    }

    func layoutCell(with recipe: Recipe) {
        nameLabel.text = "食譜名稱 (\(recipe.title.count) / 14)"
        nameTextField.text = recipe.title
        descriptionTextField.text = recipe.description
        durationTextField.text = String(recipe.cookDuration)
        quantityTextField.text = String(recipe.quantity)
        mainImageView.loadImage(recipe.mainImageURL, placeHolder: UIImage(named: "takePhoto"))
    }

    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        return tapRecognizer
    }

    @objc func pickImage() {
        delegate.willPickImage(self)
    }

    func passData() {
        guard
            let name = nameTextField.text,
            let description = descriptionTextField.text,
            let duration = durationTextField.text,
            let quantity = quantityTextField.text
        else { return }

        data.name = name
        data.description = description
        data.duration = duration
        data.quantity = quantity

        self.completion?(self.data)
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            let characterCount = updatedText.count <= 14 ? updatedText.count : 14
            nameLabel.text = "食譜名稱 (\(characterCount) / 14)"
            return updatedText.count <= 14
        }
        return true
    }
}
