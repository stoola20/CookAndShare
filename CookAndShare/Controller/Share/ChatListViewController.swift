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
        title = "訊息"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        conversations = []
        let group = DispatchGroup()
        group.enter()
        firestoreManager.fetchUserData(userId: Constant.userId) { result in
            switch result {
            case .success(let user):
                user.conversationId.forEach { conversationId in
                    group.enter()

                    self.firestoreManager.fetchConversationBy(conversationId) { result in
                        switch result {
                        case .success(let conversation):
                            self.conversations.append(conversation)
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

        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            self.conversations.sort { conversation1, conversation2 in
                guard
                    let lastMessage1 = conversation1.messages.last,
                    let lastMessage2 = conversation2.messages.last
                else { return true }
                return lastMessage1.time.seconds > lastMessage2.time.seconds
            }
            self.tableView.reloadData()
        }
    }

    func setUpTableView() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatListCell.identifier, for: indexPath)
                as? ChatListCell
        else { fatalError("Could not create ChatListCell") }
        let conversation = conversations[indexPath.row]
        if let myIdIndex = conversation.friendIds.firstIndex(of: Constant.userId),
            let lastMessage = conversation.messages.last {
            let friendId = myIdIndex == 0 ? conversation.friendIds[1] : conversation.friendIds[0]
            firestoreManager.fetchUserData(userId: friendId) { result in
                switch result {
                case .success(let user):
                    cell.layoutCell(with: user.name, imageURL: user.imageURL, lastMessage: lastMessage)
                case .failure(let error):
                    print(error)
                }
            }
        }
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
        guard
            let chatRoomVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: ChatRoomViewController.self)
            )
                as? ChatRoomViewController
        else { return }

        let conversation = conversations[indexPath.row]
        if let myIdIndex = conversation.friendIds.firstIndex(of: Constant.userId) {
            let friendId = myIdIndex == 0 ? conversation.friendIds[1] : conversation.friendIds[0]
            firestoreManager.fetchUserData(userId: friendId) { result in
                switch result {
                case .success(let friend):
                    chatRoomVC.friend = friend
                    self.navigationController?.pushViewController(chatRoomVC, animated: true)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
