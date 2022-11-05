//
//  ShareViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit

class ShareViewController: UIViewController {
    let firestoreManager = FirestoreManager.shared
    var shares: [Share] = []
    var fromPublicVC = false
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "食物分享"
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.registerCellWithNib(identifier: ShareCell.identifier, bundle: nil)
        if fromPublicVC { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "message"),
            style: .plain,
            target: self,
            action: #selector(showMessage)
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if fromPublicVC { return }
        firestoreManager.fetchSharePost { result in
            switch result {
            case .success(let shares):
                self.shares = shares
                self.shares.sort { $0.postTime.seconds > $1.postTime.seconds }
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc func showMessage() {
        let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
        guard
            let chatListVC = storyboard.instantiateViewController(withIdentifier: String(describing: ChatListViewController.self))
            as? ChatListViewController
        else { fatalError("Could not create ChatListViewController") }
        navigationController?.pushViewController(chatListVC, animated: true)
    }
}

extension ShareViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shares.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ShareCell.identifier, for: indexPath)
            as? ShareCell
        else { fatalError("Could not create share cell") }
        cell.delegate = self
        cell.layoutCell(with: shares[indexPath.row])
        return cell
    }
}

extension ShareViewController: ShareCellDelegate {
    func goToProfile(_ userId: String) {
        let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
        guard
            let publicProfileVC = storyboard.instantiateViewController(withIdentifier: String(describing: PublicProfileViewController.self))
            as? PublicProfileViewController
        else { fatalError("Could not create publicProfileVC") }
        publicProfileVC.userId = userId
        navigationController?.pushViewController(publicProfileVC, animated: true)
    }
}
