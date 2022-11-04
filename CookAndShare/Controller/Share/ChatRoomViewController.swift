//
//  ChatRoomViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import GoogleMaps

class ChatRoomViewController: UIViewController {
    var friend: User?
    var conversation: Conversation? {
        didSet {
            tableView.reloadData()
            let indexPath = IndexPath(row: conversation!.messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    private let firestoreManager = FirestoreManager.shared
    private let locationManager = CLLocationManager()
    private var location = CLLocation()

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        locationManager.delegate = self
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
        guard let text = inputTextField.text else { return }
        // 如果沒有文字，就不上傳訊息
        if text.isEmpty { return }
        // 把輸入欄位清空
        inputTextField.text = nil

        uploadMessage(contentType: .text, content: text)
    }

    func uploadMessage(contentType: ContentType, content: String) {
        guard let friend = friend else { return }
        guard let conversation = conversation else {
            let document = firestoreManager.conversationsCollection.document()
            var newConversation = Conversation()
            newConversation.channelId = document.documentID
            newConversation.friendIds = [friend.id, Constant.userId]
            let message = Message(
                senderId: Constant.userId,
                contentType: contentType.rawValue,
                content: content,
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
            "content": content,
            "contentType": contentType.rawValue,
            "time": Timestamp(date: Date())
        ]
        firestoreManager.updateConversation(channelId: conversation.channelId, message: message)
    }

    @IBAction func presentPHPicker(_ sender: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true)
    }

    @IBAction func sendLocation(_ sender: UIButton) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            let alert = UIAlertController(title: "是否傳送目前位置？", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: Constant.confirm, style: .default, handler: { action in
                let locationString = "\(self.location.coordinate.latitude),\(self.location.coordinate.longitude)"
                self.uploadMessage(contentType: .location, content: locationString)
            })
            let cancelAction = UIAlertAction(title: Constant.cancel, style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
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

// MARK: - PHPickerViewControllerDelegate
extension ChatRoomViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        if !results.isEmpty {
            let result = results.first!
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard
                        let image = image as? UIImage,
                        let self = self
                    else { return }

                    // Upload photo
                    self.firestoreManager.uploadPhoto(image: image) { result in
                        switch result {
                        case .success(let url):
                            print(url)
                            self.uploadMessage(contentType: .image, content: url.absoluteString)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
}

extension ChatRoomViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        self.location = location
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
