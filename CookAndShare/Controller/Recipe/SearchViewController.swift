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
        titleTextField.delegate = self
        ingredientTextField.delegate = self
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
        guard let resultVC = storyboard.instantiateViewController(withIdentifier: String(describing: ResultViewController.self)) as? ResultViewController,
              let searchString = textField.text
        else { fatalError("Could not instantiate result VC") }
        resultVC.searchType = .title
        resultVC.searchString = searchString
        navigationController?.pushViewController(resultVC, animated: true)
        return true
    }
}
