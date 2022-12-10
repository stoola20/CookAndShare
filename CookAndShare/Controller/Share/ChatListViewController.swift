//
//  ChatListViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit
import ESPullToRefresh

class ChatListViewController: UIViewController {
    var conversations: [Conversation] = []
    var friendsDict: [String: User] = [:]
    let firestoreManager = FirestoreManager.shared
    var header: ESRefreshHeaderAnimator {
        let header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        header.pullToRefreshDescription = "下拉更新"
        header.releaseToRefreshDescription = ""
        header.loadingDescription = "載入中..."
        return header
    }
    lazy var selectedBackground: UIView = {
        let background = UIView()
        background.backgroundColor = .white
        return background
    }()

    @IBOutlet weak var noConversationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        title = "訊息"
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
        tableView.es.addPullToRefresh(animator: header) { [weak self] in
            guard let self = self else { return }
            self.fetchChatList()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchChatList()
        noConversationLabel.isHidden = true
    }

    func setUpTableView() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }

    func fetchChatList() {
        var tempConversations: [Conversation] = []
        let group = DispatchGroup()
        group.enter()
        let myRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
        firestoreManager.getDocument(myRef) { [weak self] (result: Result<User?, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                guard let user = user else { return }
                user.conversationId.forEach { conversationId in
                    group.enter()
                    self.firestoreManager.fetchConversationBy(conversationId) { result in
                        switch result {
                        case .success(let conversation):
                            if Set(user.blockList).isDisjoint(with: Set(conversation.friendIds)) {
                                tempConversations.append(conversation)
                                if let myIdIndex = conversation.friendIds.firstIndex(of: Constant.getUserId()) {
                                    let friendId = myIdIndex == 0 ? conversation.friendIds[1] : conversation.friendIds[0]

                                    group.enter()
                                    let friendRef = FirestoreEndpoint.users.collectionRef.document(friendId)

                                    self.firestoreManager.getDocument(friendRef) { (result: Result<User?, Error>) in
                                        switch result {
                                        case .success(let friend):
                                            guard let friend = friend else { return }
                                            self.friendsDict[friendId] = friend
                                        case .failure(let error):
                                            print(error)
                                        }
                                        group.leave()
                                    }
                                }
                            }
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

        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            self.conversations = tempConversations.sorted { conversation1, conversation2 in
                guard
                    let lastMessage1 = conversation1.messages.last,
                    let lastMessage2 = conversation2.messages.last
                else { return true }
                return lastMessage1.time.seconds > lastMessage2.time.seconds
            }
            self.noConversationLabel.isHidden = self.conversations.isEmpty ? false : true
            self.tableView.reloadData()
            self.tableView.es.stopPullToRefresh()
        }
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
        if let myIdIndex = conversation.friendIds.firstIndex(of: Constant.getUserId()),
            let lastMessage = conversation.messages.last {
            let friendId = myIdIndex == 0 ? conversation.friendIds[1] : conversation.friendIds[0]
            guard let friend = friendsDict[friendId] else { fatalError("Fetch friend data error") }
            cell.layoutCell(with: friend.name, imageURL: friend.imageURL, lastMessage: lastMessage)
        }
        cell.selectedBackgroundView = selectedBackground
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
        guard let chatRoomVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: ChatRoomViewController.self)
        ) as? ChatRoomViewController
        else { return }

        let conversation = conversations[indexPath.row]
        if let myIdIndex = conversation.friendIds.firstIndex(of: Constant.getUserId()) {
            let friendId = myIdIndex == 0 ? conversation.friendIds[1] : conversation.friendIds[0]
            chatRoomVC.friend = friendsDict[friendId]
            self.navigationController?.pushViewController(chatRoomVC, animated: true)
        }
    }
}
