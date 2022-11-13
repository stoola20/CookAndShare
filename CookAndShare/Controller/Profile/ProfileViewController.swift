//
//  ProfileViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit

enum ProfileCategory: String, CaseIterable {
    case save = "我的收藏"
    case shoppingList = "採買清單"
    case setting = "編輯個人資料"
    case logout = "登出"
}

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var user: User? {
        didSet {
            tableView.reloadData()
        }
    }
    let firestoreManager = FirestoreManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        title = "個人"

        let barAppearance = UINavigationBarAppearance()
        barAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.darkBrown as Any,
            .font: UIFont.boldSystemFont(ofSize: 28)
        ]
        barAppearance.titlePositionAdjustment = UIOffset(horizontal: -200, vertical: 0)
        barAppearance.shadowColor = nil
        barAppearance.backgroundColor = .lightOrange
        navigationItem.standardAppearance = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firestoreManager.fetchUserData(userId: Constant.userId) { result in
            switch result {
            case .success(let user):
                self.user = user
            case .failure(let error):
                print(error)
            }
        }
    }

    func setUpTableView () {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor.lightOrange
        tableView.registerCellWithNib(identifier: ProfileUserCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: ProfileListCell.identifier, bundle: nil)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : ProfileCategory.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileUserCell.identifier, for: indexPath)
                as? ProfileUserCell,
                let user = user
            else { return UITableViewCell() }
            cell.layoutCell(with: user)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileListCell.identifier, for: indexPath)
                as? ProfileListCell
            else { fatalError("Could not create list cell") }
            cell.layoutCell(in: ProfileCategory.allCases[indexPath.row])
            return cell
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath == IndexPath(row: 1, section: 1) {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let shoppingListVC = storyboard.instantiateViewController(withIdentifier: String(describing: ShoppingListViewController.self))
                as? ShoppingListViewController
            else { fatalError("Could not instantiate ShoppingListViewController") }
            navigationController?.pushViewController(shoppingListVC, animated: true)
        } else if indexPath == IndexPath(row: 0, section: 1) {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let savedRecipeVC = storyboard.instantiateViewController(withIdentifier: String(describing: SavedRecipeViewController.self))
                as? SavedRecipeViewController,
                let user = user
            else { fatalError("Could not instantiate ShoppingListViewController") }
            savedRecipeVC.savedRecipsId = user.savedRecipesId
            navigationController?.pushViewController(savedRecipeVC, animated: true)
        }
    }
}
