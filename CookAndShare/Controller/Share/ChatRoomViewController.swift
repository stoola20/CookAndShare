//
//  ChatRoomViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit

class ChatRoomViewController: UIViewController {
    var friend: User?
    var messages: [Message] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
}

extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if message.senderId == Constant.userId {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: MineMessageCell.identifier, for: indexPath)
                as? MineMessageCell
            else { fatalError("could not craete MineMessageCell") }
            cell.layoutCell(with: message)
            return cell
        } else {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: OthersMessageCell.identifier, for: indexPath)
                as? OthersMessageCell
            else { fatalError("could not craete OthersMessageCell") }
            cell.layoutCell(with: message)
            return cell
        }
    }
}
