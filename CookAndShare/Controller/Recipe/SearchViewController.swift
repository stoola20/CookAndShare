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

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    func setUpView() {
        textLabel.text = Constant.searchByText
        cameraLabel.text = Constant.searchByPhoto
        randomLabel.text = Constant.searchRandomly
        titleTextField.placeholder = Constant.typeInTitle
        titleTextField.delegate = self
        ingredientTextField.placeholder = Constant.typeInIngredient
        ingredientTextField.delegate = self
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
            guard
                let resultVC = storyboard.instantiateViewController(withIdentifier: String(describing: ResultViewController.self)) as? ResultViewController
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
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        guard let text = textField.text else { return true }
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
        return true
    }
}
