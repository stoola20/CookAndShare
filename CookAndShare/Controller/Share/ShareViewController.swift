//
//  ShareViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit

class ShareViewController: UIViewController {
    let firestoreManager = FirestoreManager.shared
    var shares: [Share] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.registerCellWithNib(identifier: ShareCell.identifier, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firestoreManager.fetchSharePost { result in
            switch result {
            case .success(let shares):
                self.shares = shares
                self.shares.sort { $0.postTime.seconds > $1.postTime.seconds }
            case .failure(let error):
                print(error)
            }
        }
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
        cell.layoutCell(with: shares[indexPath.row])
        return cell
    }
}
