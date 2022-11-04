//
//  ChatRoomViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit
import FirebaseFirestore

class ChatRoomViewController: UIViewController {
    var friend: User?
    var conversation: Conversation? {
        didSet {
            tableView.reloadData()
        }
    }
    let firestoreManager = FirestoreManager.shared

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let friend = friend else {
            return
        }
        firestoreManager.fetchConversation(with: friend.id) { result in
            switch result {
            case .success(let conversation):
                self.conversation = conversation
                self.firestoreManager.addListener(channelId: conversation.channelId) { result in
                    switch result {
                    case .success(let conversation):
                        self.conversation = conversation
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.registerCellWithNib(identifier: MineMessageCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: OthersMessageCell.identifier, bundle: nil)
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        guard
            let friend = friend,
            let text = inputTextField.text
        else {
            return
        }
        // 如果沒有文字，就不上傳訊息
        if text.isEmpty { return }
        // 把輸入欄位清空
        inputTextField.text = nil

        guard let conversation = conversation else {
            let document = firestoreManager.conversationsCollection.document()
            var newConversation = Conversation()
            newConversation.channelId = document.documentID
            newConversation.friendIds = [friend.id, Constant.userId]
            let message = Message(
                senderId: Constant.userId,
                contentType: "text",
                content: text,
                time: Timestamp(date: Date())
            )
            newConversation.messages = [message]
            firestoreManager.createNewConversation(newConversation, to: document)
            self.conversation = newConversation
            firestoreManager.addListener(channelId: document.documentID) { result in
                switch result {
                case .success(let conversation):
                    self.conversation = conversation
                case .failure(let error):
                    print(error)
                }
            }
            return
        }

        let message: [String: Any] = [
            "senderId": Constant.userId,
            "content": text,
            "contentType": "text",
            "time": Timestamp(date: Date())
        ]
        firestoreManager.updateConversation(channelId: conversation.channelId, message: message)
    }
}

extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let conversation = conversation else { return 0 }
        return conversation.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let conversation = conversation else { return UITableViewCell() }
        let message = conversation.messages[indexPath.row]
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
                as? OthersMessageCell,
                let friend = friend
            else { fatalError("could not craete OthersMessageCell") }
            cell.layoutCell(with: message, friendImageURL: friend.imageURL)
            return cell
        }
    }
}
