//
//  NewRecipeViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import UIKit
import PhotosUI
import FirebaseFirestore

class NewRecipeViewController: UIViewController {
// MARK: - Property
    @IBOutlet weak var tableView: UITableView!
    var firestoreManager = FirestoreManager.shared
    var recipe = Recipe()
    var imageCell: UITableViewCell?
    var indexPathForImage: IndexPath?
    var numOfIngredients = 1
    var numOfProcedures = 1
    var ingredientDict: [Int: Ingredient] = [:]
    var procedureDict: [Int: Procedure] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
// MARK: - Action
    func setUpTableView() {
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCellWithNib(identifier: NewRecipeDescriptionCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: NewRecipeIngredientCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: NewRecipeProcedureCell.identifier, bundle: nil)
        tableView.register(NewRecipeHeaderView.self, forHeaderFooterViewReuseIdentifier: NewRecipeHeaderView.reuseIdentifier)
        tableView.register(NewRecipeFooterView.self, forHeaderFooterViewReuseIdentifier: NewRecipeFooterView.reuseIdentifier)
    }

    func presentPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true)
    }

    @objc func addIngredient() {
        numOfIngredients += 1
        tableView.insertRows(at: [IndexPath(row: numOfIngredients - 1, section: 1)], with: .automatic)
    }
    
    @objc func addProcedure() {
        numOfProcedures += 1
        tableView.insertRows(at: [IndexPath(row: numOfProcedures - 1, section: 2)], with: .automatic)
    }

    @IBAction func postRecipe(_ sender: UIButton) {
        let document = firestoreManager.recipesCollection.document()
        recipe.recipeId = document.documentID
        recipe.authorId = "me" // TODO
        recipe.time = Timestamp(date: Date())
        firestoreManager.addNewRecipe(recipe, to: document)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NewRecipeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return numOfIngredients
        default:
            return numOfProcedures
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: NewRecipeDescriptionCell.identifier, for: indexPath)
                as? NewRecipeDescriptionCell
            else { fatalError("Could not create description cell") }
            cell.completion = { [weak self] data in
                guard let self = self else { return }
                self.recipe.title = data.name
                self.recipe.description = data.description
                self.recipe.cookDuration = Int(data.duration) ?? 0
                self.recipe.quantity = Int(data.quantity) ?? 0
            }
            cell.delegate = self
            return cell

        case 1:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: NewRecipeIngredientCell.identifier, for: indexPath)
                as? NewRecipeIngredientCell
            else { fatalError("Could not create ingredient cell") }
            cell.delegate = self
            cell.nameTextField.text = nil
            cell.quantityTextField.text = nil
            return cell

        default:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: NewRecipeProcedureCell.identifier, for: indexPath)
                as? NewRecipeProcedureCell
            else { fatalError("Could not create procedure cell") }
            cell.layoutCell(with: indexPath)
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension NewRecipeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewRecipeHeaderView.reuseIdentifier)
                as? NewRecipeHeaderView
        else { fatalError("Could not create header view.") }
        headerView.label.text = section == 1 ? Constant.ingredient : Constant.procedure
        return headerView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 { return nil }

        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewRecipeFooterView.reuseIdentifier)
                as? NewRecipeFooterView
        else { fatalError("Could not create footer view.") }

        if section == 1 {
            footerView.button.addTarget(self, action: #selector(addIngredient), for: .touchUpInside)
            footerView.button.setTitle(Constant.ingredient, for: .normal)
            return footerView
        } else {
            footerView.button.addTarget(self, action: #selector(addProcedure), for: .touchUpInside)
            footerView.button.setTitle(Constant.procedure, for: .normal)
            return footerView
        }
    }
}

// MARK: - NewRecipeDescriptionDelegate
extension NewRecipeViewController: NewRecipeDescriptionDelegate {
    func willPickImage(_ cell: NewRecipeDescriptionCell) {
        self.imageCell = cell as NewRecipeDescriptionCell
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        self.indexPathForImage = indexPath

        presentPHPicker()
    }
}

// MARK: - NewRecipeIngredientDelegate
extension NewRecipeViewController: NewRecipeIngredientDelegate {
    func didDelete(_ cell: NewRecipeIngredientCell, _ ingredient: Ingredient) {
        numOfIngredients -= 1

        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }
        tableView.deleteRows(at: [indexPath], with: .left)
        self.recipe.ingredients.remove(at: indexPath.row)
        self.ingredientDict.removeValue(forKey: indexPath.row)
        
        var newIngredientNames: [String] = []
        self.recipe.ingredients.forEach { ingredient in
            newIngredientNames.append(ingredient.name)
        }

        let sortedIngredient = ingredientDict.sorted { $0.key < $1.key }
        var index = 0
        var newIngredientDict = [Int: Ingredient]()
        sortedIngredient.forEach { _, value in
            newIngredientDict[index] = value
            index += 1
        }

        self.recipe.ingredientNames = newIngredientNames
        self.ingredientDict = newIngredientDict
    }

    func didAddIngredient(_ cell: NewRecipeIngredientCell, _ ingredient: Ingredient) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }

        ingredientDict[indexPath.row] = ingredient

        var ingredients = [Ingredient]()
        var newIngredientNames: [String] = []
        let sortedDict = ingredientDict.sorted { $0.key < $1.key }

        sortedDict.forEach { _, value in
            ingredients.append(value)
        }

        ingredients.forEach { ingredient in
            newIngredientNames.append(ingredient.name)
        }
        self.recipe.ingredientNames = newIngredientNames
        self.recipe.ingredients = ingredients
    }
}

// MARK: - NewRecipeProcedureDelegate
extension NewRecipeViewController: NewRecipeProcedureDelegate {
    func willPickImage(_ cell: NewRecipeProcedureCell) {
        self.imageCell = cell as NewRecipeProcedureCell
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        self.indexPathForImage = indexPath
        
        presentPHPicker()
    }
    
    func didDelete(_ cell: NewRecipeProcedureCell) {
        numOfProcedures -= 1
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }
        tableView.deleteRows(at: [indexPath], with: .left)
        self.procedureDict.removeValue(forKey: indexPath.row)
        
        let sortedProcedure = procedureDict.sorted { $0.key < $1.key }
        var index = 0
        var newProcedures = [Procedure]()
        var newProcedureDict = [Int : Procedure]()
        sortedProcedure.forEach { _, value in
            newProcedureDict[index] = value
            newProcedures.append(value)
            index += 1
        }
        
        for index in 0..<newProcedures.count {
            var procedure = newProcedures[index]
            procedure.step = index
            newProcedures[index] = procedure
        }
        self.recipe.procedures = newProcedures
        self.procedureDict = newProcedureDict
        print(self.procedureDict)
        print(self.recipe.procedures)
    }
    
    func didAddProcedure(_ cell: NewRecipeProcedureCell, description: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }

        procedureDict[indexPath.row] = Procedure(step: 0, description: description, imageURL: "")
        print(self.procedureDict)
        var procedures = [Procedure]()
        let sortedDict = procedureDict.sorted { $0.key < $1.key }
        sortedDict.forEach { key, value in
            procedures.append(value)
        }

        for index in 0..<procedures.count {
            var procedure = procedures[index]
            procedure.step = index
            procedures[index] = procedure
        }
        
        self.recipe.procedures = procedures
        print(self.recipe.procedures)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension NewRecipeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if !results.isEmpty {
            let result = results.first!
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard
                        let image = image as? UIImage,
                        let self = self,
                        let indexPath = self.indexPathForImage
                    else { return }
                    
                    // Upload photo
                    self.firestoreManager.uploadPhoto(image: image) { result in
                        switch result {
                        case .success(let url):
                            print(url)
                            if self.imageCell is NewRecipeDescriptionCell {
                                self.recipe.mainImageURL = url.absoluteString
                            } else if self.imageCell is NewRecipeProcedureCell {
                                self.recipe.procedures[indexPath.row].imageURL = url.absoluteString
                                print("===\(self.recipe.procedures)")
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                    
                    // update image
                    DispatchQueue.main.async {
                    
                        if self.imageCell is NewRecipeDescriptionCell {
                            guard let cell = self.tableView.cellForRow(at: indexPath) as? NewRecipeDescriptionCell else { fatalError("Wrong cell") }
                            cell.mainImageView.image = image
                        } else if self.imageCell is NewRecipeProcedureCell {
                            guard let cell = self.tableView.cellForRow(at: indexPath) as? NewRecipeProcedureCell else { fatalError("Wrong cell") }
                            cell.procedureImageView.image = image
                        }
                    }
                }
            }
        }
    }
}
