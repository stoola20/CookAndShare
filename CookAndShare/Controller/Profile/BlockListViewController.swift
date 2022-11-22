//
//  BlockListViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/22.
//

import UIKit

class BlockListViewController: UIViewController {
    var blockedUsers: [User] = []
    let firestoreManager = FirestoreManager.shared
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        title = "封鎖名單"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBlockUsers()
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor.lightOrange
        tableView.registerCellWithNib(identifier: BLockListCell.identifier, bundle: nil)
    }

    func fetchBlockUsers() {
        let group = DispatchGroup()
        blockedUsers.removeAll()
        group.enter()
        firestoreManager.fetchUserData(userId: Constant.getUserId()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                user.blockList.forEach { blockId in
                    group.enter()
                    self.firestoreManager.fetchUserData(userId: blockId) { result in
                        switch result {
                        case .success(let user):
                            self.blockedUsers.append(user)
                            group.leave()
                        case .failure(let error):
                            print(error)
                            group.leave()
                        }
                    }
                }
                group.leave()
            case .failure(let error):
                print(error)
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
        }
    }
}

extension BlockListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BLockListCell.identifier, for: indexPath) as? BLockListCell
        else { fatalError("Could not create cell") }
        cell.layoutCell(with: blockedUsers[indexPath.row])
        cell.completion = { [weak self] cell in
            guard
                let self = self,
                let selectedIndexPath = self.tableView.indexPath(for: cell)
            else { return }
            self.firestoreManager.updateUserBlocklist(
                userId: Constant.getUserId(),
                blockId: self.blockedUsers[selectedIndexPath.row].id,
                hasBlocked: true
            )
            self.blockedUsers.remove(at: selectedIndexPath.row)
            self.tableView.deleteRows(at: [selectedIndexPath], with: .left)
        }
        return cell
    }
}
