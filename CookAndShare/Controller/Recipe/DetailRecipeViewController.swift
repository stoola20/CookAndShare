//
//  DetailRecipeViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

enum DetailRecipeSection: CaseIterable {
    case banner
    case ingredient
    case procedure
}

class DetailRecipeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            updateSaveButton()
        }
    }
    @IBOutlet weak var likeButton: UIButton! {
        didSet {
            updateLikeButton()
        }
    }
    let firestoreManager = FirestoreManager.shared
    var hasLiked = false
    var hasSaved = false
    var recipe: Recipe? {
        didSet {
            guard let recipe = recipe else { return }
            hasLiked = recipe.likes.contains(Constant.userId)
            hasSaved = recipe.saves.contains(Constant.userId)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func updateLikeButton() {
        let likeImage = hasLiked
        ? UIImage(systemName: "heart.fill")
        : UIImage(systemName: "heart")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    func updateSaveButton() {
        let saveImage = hasSaved
        ? UIImage(systemName: "bookmark.fill")
        : UIImage(systemName: "bookmark")
        saveButton.setImage(saveImage, for: .normal)
    }
    
    func setUpTableView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.registerCellWithNib(identifier: DetailBannerCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: DetailIngredientCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: DetailProcedureCell.identifier, bundle: nil)
        tableView.register(DetailRecipeHeaderView.self, forHeaderFooterViewReuseIdentifier: DetailRecipeHeaderView.reuseIdentifier)
    }

    @IBAction func saveRecipe(_ sender: UIButton) {
        guard let recipe = recipe else { return }
        firestoreManager.updateRecipeSaves(recipeId: recipe.recipeId, userId: Constant.userId, hasSaved: hasSaved)
        firestoreManager.updateUserSaves(recipeId: recipe.recipeId, userId: Constant.userId, hasSaved: hasSaved)
        hasSaved.toggle()
        updateSaveButton()
    }
    
    @IBAction func likeRecipe(_ sender: UIButton) {
        guard let recipe = recipe else { return }
        firestoreManager.updateRecipeLikes(recipeId: recipe.recipeId, userId: Constant.userId, hasLiked: hasLiked)
        hasLiked.toggle()
        updateLikeButton()
    }
    
    @IBAction func backToLobby(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DetailRecipeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        DetailRecipeSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipe = recipe else { return 0 }
        switch section {
        case 0:
            return 1
        case 1:
            return recipe.ingredients.count
        default:
            return recipe.procedures.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipe = recipe else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailBannerCell.identifier, for: indexPath) as? DetailBannerCell
            else { fatalError("Could not create banner cell") }
            cell.layoutCell(with: recipe)
            return cell

        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailIngredientCell.identifier, for: indexPath) as? DetailIngredientCell
            else { fatalError("Could not create ingredient cell") }
            cell.layoutCell(with: recipe.ingredients[indexPath.row])
            return cell

        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailProcedureCell.identifier, for: indexPath) as? DetailProcedureCell
            else { fatalError("Could not create procedure cell") }
            cell.layoutCell(with: recipe.procedures[indexPath.row], at: indexPath)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension DetailRecipeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let recipe = recipe else { return nil }
        switch section {
        case 0: return nil
        default:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DetailRecipeHeaderView.reuseIdentifier) as? DetailRecipeHeaderView
            else { fatalError("Could not create header view") }
            headerView.layoutHeader(with: recipe, in: section)
            headerView.delegate = self
            return headerView
        }
    }
}

extension DetailRecipeViewController: DetailRecipeHeaderViewDelegate {
    func willAddIngredient() {
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
        guard
            let addToListVC = storyboard.instantiateViewController(withIdentifier: String(describing: AddToShoppingListVC.self))
            as? AddToShoppingListVC,
            let recipe = recipe
        else { fatalError("Could not create AddToShoppingListVC") }
        addToListVC.initialIngredients = recipe.ingredients
        present(addToListVC, animated: true)
    }
}