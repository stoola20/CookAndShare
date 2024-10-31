//
//  AddToShoppingListVC.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit
import SPAlert

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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addToListButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpUI()
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorColor = UIColor.lightOrange
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.registerCellWithNib(identifier: ShoppingListCell.identifier, bundle: nil)
    }

    func setUpUI() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = UIColor.darkBrown
        titleLabel.layer.shadowColor = UIColor.darkBrown?.cgColor
        titleLabel.layer.shadowRadius = 2
        titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)

        addToListButton.backgroundColor = UIColor.darkBrown
        addToListButton.layer.cornerRadius = 25
        addToListButton.setTitleColor(UIColor.background, for: .normal)
    }

    @IBAction func addToShoppingList(_ sender: UIButton) {
        let alertView = AlertAppleMusic17View(title: "已加入採買清單", subtitle: nil, icon: nil)
        alertView.duration = 1
        alertView.present(on: self.view) {
            self.dismiss(animated: true)
        }

        for index in selectedIndex {
            let ingredient = initialIngredients[index]
            coreDataManager.addItem(name: ingredient.name, quantity: ingredient.quantity)
        }
    }
}

extension AddToShoppingListVC: UITableViewDataSource, UITableViewDelegate {
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}
