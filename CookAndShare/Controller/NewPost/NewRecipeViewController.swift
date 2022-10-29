//
//  NewRecipeViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import UIKit
import FirebaseFirestore

class NewRecipeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var firestoreManager = FirestoreManager.shared
    var numOfIngredients = 3
    var numOfProcedures = 3
    var recipe = Recipe()
    var ingredientDict: [Int : Ingredient] = [:]
    var procedureDict: [Int : Procedure] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
    }
    
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
    }
}

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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewRecipeDescriptionCell.identifier, for: indexPath) as? NewRecipeDescriptionCell else { fatalError("Could not create description cell") }
            cell.completion = { [weak self] data in
                guard let self = self else { return }
                self.recipe.title = data.name
                self.recipe.description = data.description
                self.recipe.cookDuration = Int(data.duration) ?? 0
                self.recipe.quantity = Int(data.quantity) ?? 0
            }
            return cell

        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewRecipeIngredientCell.identifier, for: indexPath) as? NewRecipeIngredientCell else { fatalError("Could not create ingredient cell") }
            cell.delegate = self
            return cell

        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewRecipeProcedureCell.identifier, for: indexPath) as? NewRecipeProcedureCell else { fatalError("Could not create procedure cell") }
            cell.layoutCell(with: indexPath)
            cell.delegate = self
            return cell
        }
    }
}

extension NewRecipeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewRecipeHeaderView.reuseIdentifier) as? NewRecipeHeaderView else { fatalError("Could not create header view.") }
        headerView.label.text = section == 1 ? Constant.ingredient : Constant.procedure
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 { return nil }

        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewRecipeFooterView.reuseIdentifier) as? NewRecipeFooterView else { fatalError("Could not create footer view.") }

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

extension NewRecipeViewController: NewRecipeIngredientDelegate {
    func didDelete(_ cell: NewRecipeIngredientCell, _ ingredient: Ingredient) {
        numOfIngredients -= 1
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }
        tableView.deleteRows(at: [indexPath], with: .left)
        let newIngredients = self.recipe.ingredients.drop { element in
            element.name == ingredient.name
        }

        print("===\(ingredientDict)")
        self.recipe.ingredients = Array(newIngredients)
        print(self.recipe.ingredients)
    }
    
    func didAddIngredient(_ cell: NewRecipeIngredientCell, _ ingredient: Ingredient) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }

        var ingredients = [Ingredient]()
        ingredientDict[indexPath.row] = ingredient
        print("===\(self.ingredientDict)")
        let sortedDict = ingredientDict.sorted { $0.key < $1.key }
        sortedDict.forEach { key, value in
            ingredients.append(value)
        }
        self.recipe.ingredients = ingredients
        print(self.recipe.ingredients)
    }
}

extension NewRecipeViewController: NewRecipeProcedureDelegate {
    func didDelete(_ cell: NewRecipeProcedureCell) {
        numOfProcedures -= 1
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }
        var procedures = [Procedure]()
        procedureDict.removeValue(forKey: indexPath.row)
        procedureDict.forEach { key, value in
            procedures.append(value)
        }
        self.recipe.procedures = procedures
        print(self.recipe.procedures)
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.reloadData()
    }
    
    func didAddProcedure(_ cell: NewRecipeProcedureCell, description: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }

        let procedure = Procedure(step: indexPath.row + 1, description: description, imageURL: "")
        var procedures = [Procedure]()
        procedureDict[indexPath.row] = procedure
        procedureDict.forEach { key, value in
            procedures.append(value)
        }
        self.recipe.procedures = procedures
        print(self.recipe.procedures)
    }
}
