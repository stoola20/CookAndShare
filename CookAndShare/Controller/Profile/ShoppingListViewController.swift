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
            alertStackView.isHidden = items.isEmpty ? false : true
        }
    }
    @IBOutlet weak var alertStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        title = "採買清單"
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addItem)
        )
        navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertStackView.isHidden = true
        guard let items = coreDataManager.fetchItem() else { return }
        self.items = items
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorColor = UIColor.lightOrange
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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

        let okAction = UIAlertAction(title: Constant.confirm, style: .default) { [weak self] _ in
            guard
                let self = self,
                let name = alert.textFields?[0].text,
                let quantity = alert.textFields?[1].text,
                !name.isEmpty,
                !quantity.isEmpty
            else { return }
            self.coreDataManager.addItem(name: name, quantity: quantity)
            guard let items = self.coreDataManager.fetchItem() else { return }
            self.items = items
        }
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }

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
