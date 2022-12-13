//
//  NewRecipeViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import SPAlert

class NewRecipeViewController: UIViewController {
// MARK: - Property
    @IBOutlet weak var tableView: UITableView!
    var firestoreManager = FirestoreManager.shared
    var recipe = Recipe() {
        didSet {
            for index in 0..<recipe.ingredients.count {
                let ingredient = recipe.ingredients[index]
                ingredientDict[index] = ingredient
            }

            for index in 0..<recipe.procedures.count {
                let procedure = recipe.procedures[index]
                procedureDict[index] = procedure
            }
        }
    }
    var imageCell: UITableViewCell?
    var indexPathForImage: IndexPath?
    var ingredientDict: [Int: Ingredient] = [:]
    var procedureDict: [Int: Procedure] = [:]
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "發布",
            style: .plain,
            target: self,
            action: #selector(postRecipe(_:))
        )

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

// MARK: - Action
    func setUpTableView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCellWithNib(identifier: NewRecipeDescriptionCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: NewRecipeIngredientCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: NewRecipeProcedureCell.identifier, bundle: nil)
    }

    func presentImagePicker() {
        let controller = UIAlertController(title: "請選擇照片來源", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cameraAction)
        controller.addAction(photoLibraryAction)
        controller.addAction(cancelAction)

        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        present(controller, animated: true, completion: nil)
    }

    @objc func addIngredient() {
        let rowNum = tableView.numberOfRows(inSection: 1)

        guard
            let cell = tableView.cellForRow(at: IndexPath(row: rowNum - 1, section: 1)) as? NewRecipeIngredientCell,
            let nameText = cell.nameTextField.text,
            let quantityText = cell.quantityTextField.text
        else { return }

        if nameText.isEmpty || quantityText.isEmpty {
            return
        } else {
            tableView.insertRows(at: [IndexPath(row: rowNum, section: 1)], with: .automatic)
        }
    }

    @objc func addProcedure() {
        let rowNum = tableView.numberOfRows(inSection: 2)

        guard
            let cell = tableView.cellForRow(at: IndexPath(row: rowNum - 1, section: 2)) as? NewRecipeProcedureCell,
            let procedureText = cell.procedureTextField.text
        else { return }

        if !procedureText.isEmpty {
            tableView.insertRows(at: [IndexPath(row: rowNum, section: 2)], with: .automatic)
            tableView.scrollToRow(at: IndexPath(row: rowNum, section: 2), at: .top, animated: true)
        }
    }

    @IBAction func postRecipe(_ sender: UIButton) {
        if recipe.title.isEmpty || recipe.mainImageURL.isEmpty || recipe.ingredients.isEmpty || recipe.procedures.isEmpty {
            let alert = UIAlertController(
                title: "請檢查下列欄位是否為空白：",
                message: "1. 食譜主圖\n2. 食譜名稱\n3. 食材\n4. 步驟",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "了解", style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: true)
        } else {
            let alertView = SPAlertView(message: "成功上傳食譜")
            alertView.duration = 1.3
            alertView.present(haptic: .warning) {
                self.navigationController?.popViewController(animated: true)
            }
            if recipe.recipeId.isEmpty {
                let document = FirestoreEndpoint.recipes.collectionRef.document()
                recipe.recipeId = document.documentID
                recipe.authorId = Constant.getUserId()
                recipe.time = Timestamp(date: Date())
                firestoreManager.setData(recipe, to: document)

                let userRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
                firestoreManager.arrayUnionString(
                    docRef: userRef,
                    field: Constant.recipesId,
                    value: document.documentID
                )
            } else {
                try? FirestoreEndpoint.recipes.collectionRef.document(recipe.recipeId).setData(from: recipe, merge: true)
            }
        }
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
            return recipe.ingredients.count + 1
        default:
            return recipe.procedures.count + 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: NewRecipeDescriptionCell.identifier,
                    for: indexPath
                )
                as? NewRecipeDescriptionCell
            else { fatalError("Could not create description cell") }
            cell.layoutCell(with: recipe)
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
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: NewRecipeIngredientCell.identifier,
                    for: indexPath
                )
                as? NewRecipeIngredientCell
            else { fatalError("Could not create ingredient cell") }
            cell.delegate = self

            if indexPath.row < self.recipe.ingredients.count {
                cell.nameTextField.text = self.recipe.ingredients[indexPath.row].name
                cell.quantityTextField.text = self.recipe.ingredients[indexPath.row].quantity
                cell.deleteButton.isHidden = false
            } else {
                cell.nameTextField.text = nil
                cell.quantityTextField.text = nil
                cell.deleteButton.isHidden = true
            }

            return cell

        default:
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: NewRecipeProcedureCell.identifier,
                    for: indexPath
                )
                as? NewRecipeProcedureCell
            else { fatalError("Could not create procedure cell") }
            cell.layoutCell(with: indexPath)
            cell.delegate = self

            if indexPath.row < self.recipe.procedures.count {
                cell.procedureTextField.text = self.recipe.procedures[indexPath.row].description
                cell.procedureImageView.loadImage(
                    self.recipe.procedures[indexPath.row].imageURL,
                    placeHolder: UIImage(named: "takePhoto")
                )
                cell.deleteButton.isHidden = false
            } else {
                cell.procedureTextField.text = nil
                cell.procedureImageView.image = UIImage(named: "takePhoto")
                cell.deleteButton.isHidden = true
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension NewRecipeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor.darkBrown
        label.translatesAutoresizingMaskIntoConstraints = false

        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        switch section {
        case 0:
            label.text = "簡介"
        case 1:
            label.text = Constant.ingredient
        default:
            label.text = Constant.procedure
        }
        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
}

// MARK: - NewRecipeDescriptionDelegate
extension NewRecipeViewController: NewRecipeDescriptionDelegate {
    func willPickImage(_ cell: NewRecipeDescriptionCell) {
        self.imageCell = cell as NewRecipeDescriptionCell
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        self.indexPathForImage = indexPath

        presentImagePicker()
    }
}

// MARK: - NewRecipeIngredientDelegate
extension NewRecipeViewController: NewRecipeIngredientDelegate {
    func didDelete(_ cell: NewRecipeIngredientCell, _ ingredient: Ingredient) {

        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }
        self.recipe.ingredients.remove(at: indexPath.row)
        self.ingredientDict.removeValue(forKey: indexPath.row)

        var newIngredientNames: [String] = []
        self.recipe.ingredients.forEach { ingredient in
            newIngredientNames.append(ingredient.name)
        }

        let sortedIngredient = ingredientDict.sorted { $0.key < $1.key }
        var index = 0
        var newIngredientDict: [Int: Ingredient] = [:]
        sortedIngredient.forEach { _, value in
            newIngredientDict[index] = value
            index += 1
        }

        self.recipe.ingredientNames = newIngredientNames
        self.ingredientDict = newIngredientDict
        tableView.deleteRows(at: [indexPath], with: .left)
    }

    func didAddIngredient(_ cell: NewRecipeIngredientCell, _ ingredient: Ingredient) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }

        ingredientDict[indexPath.row] = ingredient

        var ingredients: [Ingredient] = []
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

        presentImagePicker()
    }

    func didDelete(_ cell: NewRecipeProcedureCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }
        self.procedureDict.removeValue(forKey: indexPath.row)

        let sortedProcedure = procedureDict.sorted { $0.key < $1.key }
        var index = 0
        var newProcedures: [Procedure] = []
        var newProcedureDict: [Int: Procedure] = [:]
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
        tableView.reloadData()
    }

    func didAddProcedure(_ cell: NewRecipeProcedureCell, description: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Wrong indexPath") }
        if indexPath.row > self.recipe.procedures.count - 1 {
            procedureDict[indexPath.row] = Procedure(step: 0, description: description, imageURL: "")
            var procedures: [Procedure] = []
            let sortedDict = procedureDict.sorted { $0.key < $1.key }
            sortedDict.forEach { _, value in
                procedures.append(value)
            }

            for index in 0..<procedures.count {
                var procedure = procedures[index]
                procedure.step = index
                procedures[index] = procedure
            }

            self.recipe.procedures = procedures
        } else {
            self.procedureDict[indexPath.row]?.description = description
            self.recipe.procedures[indexPath.row].description = description
        }
    }
}

extension NewRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard
            let userPickedImage = info[.editedImage] as? UIImage,
            let indexPath = self.indexPathForImage
        else { fatalError("Wrong cell") }

        // Upload photo
        self.firestoreManager.uploadPhoto(image: userPickedImage) { result in
            switch result {
            case .success(let url):
                print(url)
                if self.imageCell is NewRecipeDescriptionCell {
                    self.recipe.mainImageURL = url.absoluteString
                } else if self.imageCell is NewRecipeProcedureCell {
                    if indexPath.row > self.recipe.procedures.count - 1 {
                        var procedure = Procedure()
                        procedure.imageURL = url.absoluteString
                        self.procedureDict[indexPath.row] = procedure

                        var procedures: [Procedure] = []
                        let sortedDict = self.procedureDict.sorted { $0.key < $1.key }
                        sortedDict.forEach { _, value in
                            procedures.append(value)
                        }

                        for index in 0..<procedures.count {
                            var procedure = procedures[index]
                            procedure.step = index
                            procedures[index] = procedure
                        }

                        self.recipe.procedures = procedures
                    } else {
                        self.recipe.procedures[indexPath.row].imageURL = url.absoluteString
                        self.procedureDict[indexPath.row]?.imageURL = url.absoluteString
                    }
                }
            case .failure(let error):
                print(error)
            }
        }

        // update image
        DispatchQueue.main.async {
            if self.imageCell is NewRecipeDescriptionCell {
                guard let cell = self.tableView.cellForRow(at: indexPath) as? NewRecipeDescriptionCell
                else { fatalError("Wrong cell") }
                cell.mainImageView.image = userPickedImage
                cell.mainImageView.contentMode = .scaleAspectFill
            } else if self.imageCell is NewRecipeProcedureCell {
                guard let cell = self.tableView.cellForRow(at: indexPath) as? NewRecipeProcedureCell
                else { fatalError("Wrong cell") }
                cell.procedureImageView.image = userPickedImage
            }
        }
        dismiss(animated: true)
    }
}
