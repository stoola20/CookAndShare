//
//  AddToShoppingListVC.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit

class AddToShoppingListVC: UIViewController {
    let coreDataManager = CoreDataManager.shared
    var initialIngredients: [Ingredient] = [] {
        didSet {
            for index in 0..<initialIngredients.count {
                selectedIndex.append(index)
            }
        }
    }
    var selectedIndex: [Int] = []

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.registerCellWithNib(identifier: ShoppingListCell.identifier, bundle: nil)
    }

    @IBAction func addToShoppingList(_ sender: UIButton) {
        for index in selectedIndex {
            let ingredient = initialIngredients[index]
            coreDataManager.addItem(name: ingredient.name, quantity: ingredient.quantity)
        }
        dismiss(animated: true)
    }
}

extension AddToShoppingListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        initialIngredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListCell.identifier, for: indexPath)
            as?  ShoppingListCell
        else { fatalError("Could not create shopping list cell") }
        cell.checkButton.tag = indexPath.row
        cell.addCompletion = { [weak self] cell in
            guard
                let self = self,
                let indexPath = self.tableView.indexPath(for: cell)
            else { return }
            self.selectedIndex.append(indexPath.row)
            self.selectedIndex.sort()
        }

        cell.deleteCompletion = { [weak self] tag in
            guard
                let self = self,
                let firstIndex = self.selectedIndex.firstIndex(of: tag)
            else { return }
            self.selectedIndex.remove(at: firstIndex)
        }
        cell.layoutCell(with: initialIngredients[indexPath.row])
        return cell
    }
}
