//
//  ShoppingListViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit
import CoreData

class ShoppingListViewController: UIViewController {
    let coreDataManager = CoreDataManager.shared
    var items: [ShoppingList] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addItem))
        navigationItem.rightBarButtonItems = [editButtonItem, addButton]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let items = coreDataManager.fetchItem() else { return }
        self.items = items
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.registerCellWithNib(identifier: ShoppingListCell.identifier, bundle: nil)
    }

    @objc func addItem() {
        let alert = UIAlertController(title: Constant.pleaseFillIn, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = Constant.ingredientName
        }
        alert.addTextField { textField in
            textField.placeholder = Constant.ingredientQuantity
        }
        
        let okAction = UIAlertAction(title: Constant.confirm, style: .default, handler: { action in
            guard
                let name = alert.textFields?[0].text,
                let quantity = alert.textFields?[1].text
            else { return }
            self.coreDataManager.addItem(name: name, quantity: quantity)
            guard let items = self.coreDataManager.fetchItem() else { return }
            self.items = items
        })
        let cancelAction = UIAlertAction(title: Constant.cancel, style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ShoppingListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListCell.identifier, for: indexPath)
            as? ShoppingListCell
        else { fatalError("Could not create shopping list cell") }
        cell.layoutCell(with: items[indexPath.row])
        return cell
    }
}

extension ShoppingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            coreDataManager.deleteItem(item: items[indexPath.row])
            self.items.remove(at: indexPath.row)
        }
    }
}
