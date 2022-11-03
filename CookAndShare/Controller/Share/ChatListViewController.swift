//
//  ChatListViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit

class ChatListViewController: UIViewController {
    var conversations: [Conversation] = []
    let firestoreManager = FirestoreManager.shared
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    func setUpTableView() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
    }
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatListCell.identifier, for: indexPath) as? ChatListCell
        else { fatalError("Could not create ChatListCell") }
        let conversation = conversations[indexPath.row]
        if let myIdIndex = conversation.friendId.firstIndex(of: Constant.userId) {
            let friendId = myIdIndex == 0 ? conversation.friendId[1] : conversation.friendId[0]
            firestoreManager.fetchUserData(userId: friendId) { result in
                switch result {
                case .success(let user):
                    cell.layoutCell(with: user.name, imageURL: user.imageURL, lastMessage: conversation.messages.last!.content, lastTime: "早上 7:00")
                case .failure(let error):
                    print(error)
                }
            }
        }
        return cell
    }
}
