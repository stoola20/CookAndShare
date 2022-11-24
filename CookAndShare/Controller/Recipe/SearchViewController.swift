//
//  SearchViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var randomLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var foodRecognitionButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        title = Constant.search
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    func setUpView() {
        textLabel.text = Constant.searchByText
        cameraLabel.text = Constant.searchByPhoto
        randomLabel.text = Constant.searchRandomly
        let button = UIButton(type: .custom)
        

        titleTextField.placeholder = Constant.typeInTitle
        titleTextField.delegate = self
        titleTextField.backgroundColor = UIColor.lightOrange
        titleTextField.textColor = UIColor.darkBrown
        titleTextField.font = UIFont.systemFont(ofSize: 18)
        titleTextField.returnKeyType = .search

        ingredientTextField.placeholder = Constant.typeInIngredient
        ingredientTextField.delegate = self
        ingredientTextField.backgroundColor = UIColor.lightOrange
        ingredientTextField.textColor = UIColor.darkBrown
        ingredientTextField.font = UIFont.systemFont(ofSize: 18)
        ingredientTextField.returnKeyType = .search

        textLabel.textColor = UIColor.darkBrown
        cameraLabel.textColor = UIColor.darkBrown
        randomLabel.textColor = UIColor.darkBrown

        foodRecognitionButton.backgroundColor = UIColor.darkBrown
        foodRecognitionButton.setTitleColor(UIColor.background, for: .normal)
        foodRecognitionButton.layer.cornerRadius = 25
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
            guard
                let resultVC = storyboard.instantiateViewController(
                    withIdentifier: String(describing: ResultViewController.self)
                )
            as? ResultViewController
            else { fatalError("Could not instantiate result VC") }
            resultVC.searchType = .random
            navigationController?.pushViewController(resultVC, animated: true)
        }
    }

    @IBAction func showFoodRecognition(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
        guard
            let foodRecognitionVC = storyboard.instantiateViewController(withIdentifier: String(describing: FoodRecognitionViewController.self))
            as? FoodRecognitionViewController
        else { fatalError("Could not create foodRecognitionVC") }
        foodRecognitionVC.title = Constant.foodRecognition
        navigationController?.pushViewController(foodRecognitionVC, animated: true)
    }

    @objc func dismissKeyboard() {
        titleTextField.resignFirstResponder()
        ingredientTextField.resignFirstResponder()
    }

    @objc func searchRecipe(_ textField: UITextField) {
        textField.resignFirstResponder()

        guard let text = textField.text else { return }
        if !text.isEmpty {
            let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
            guard
                let resultVC = storyboard.instantiateViewController(withIdentifier: String(describing: ResultViewController.self)) as? ResultViewController,
                let searchString = textField.text
            else { fatalError("Could not instantiate result VC") }
            resultVC.searchType = textField == titleTextField ? .title : .ingredient
            resultVC.searchString = searchString
            navigationController?.pushViewController(resultVC, animated: true)
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchRecipe(textField)
        return true
    }
}
