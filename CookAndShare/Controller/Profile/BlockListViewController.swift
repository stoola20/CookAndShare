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
    @IBOutlet weak var alertLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        title = "封鎖名單"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertLabel.isHidden = true
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
        let userRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
        firestoreManager.getDocument(userRef) { [weak self] (result: Result<User?, Error>) in
            switch result {
            case .success(let user):
                guard let self = self, let user = user else { return }
                if user.blockList.isEmpty {
                    self.alertLabel.isHidden = false
                }
                user.blockList.forEach { blockId in
                    group.enter()
                    let userRef = FirestoreEndpoint.users.collectionRef.document(blockId)
                    self.firestoreManager.getDocument(userRef) { [weak self] (result: Result<User?, Error>) in
                        switch result {
                        case .success(let blockedUser):
                            guard let self = self, let blockedUser = blockedUser else { return }
                            self.blockedUsers.append(blockedUser)
                        case .failure(let error):
                            print(error)
                        }
                        group.leave()
                    }
                }
            case .failure(let error):
                print(error)
            }
            group.leave()
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
