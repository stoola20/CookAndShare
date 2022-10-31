//
//  ShoppingListViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit

class ShoppingListViewController: UIViewController {
    let coreDataManager = CoreDataManager.shared
    var items: [ShoppingList] = []
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let items = coreDataManager.fetchItem() else { return }
        self.items = items
    }
    
    func setUpTableView() {
        tableView.dataSource = self
        tableView.registerCellWithNib(identifier: ShoppingListCell.identifier, bundle: nil)
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
