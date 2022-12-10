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
import AVFoundation
import Hero

class ChatRoomViewController: UIViewController {
    private var timer: Timer?
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var numOfRecorder: Int = 0
    private var playingRecord = false
    var friend: User?
    private var messages: [[Message]] = [] {
        didSet {
            guard let lastSection = messages.last else { return }
            tableView.reloadData()
            let indexPath = IndexPath(row: lastSection.count - 1, section: messages.count - 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    private var conversation: Conversation? {
        didSet {
            assembleGroupedMessages()
        }
    }
    private let firestoreManager = FirestoreManager.shared
    private let locationManager = CLLocationManager()
    private var location = CLLocation()

    @IBOutlet weak var sendVoiceButton: UIButton!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var wrapperViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var recordViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()
        setUpUI()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        inputTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideAudioRecordView))
        view.addGestureRecognizer(tap)
        guard let friend = friend else { return }
        title = friend.name

        // voice
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            numOfRecorder = number
        }
        sendVoiceButton.isHidden = true
        configRecordSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchConversation()
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.registerCellWithNib(identifier: MineMessageCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: MineImageCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: MineLocationCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: MineVoiceCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: OthersMessageCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: OtherImageCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: OtherLocationCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: OtherVoiceCell.identifier, bundle: nil)
    }

    func setUpUI() {
        view.backgroundColor = UIColor.background
        inputTextField.backgroundColor = UIColor.background
        inputTextField.textColor = UIColor.darkBrown

        recordButton.layer.borderColor = UIColor.myOrange?.cgColor
        recordButton.layer.borderWidth = 2
        recordButton.layer.cornerRadius = 25
        recordButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        recordButton.tintColor = UIColor.systemRed

        playAndPauseButton.layer.borderColor = UIColor.myOrange?.cgColor
        playAndPauseButton.layer.borderWidth = 2
        playAndPauseButton.layer.cornerRadius = 25
        playAndPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playAndPauseButton.tintColor = UIColor.darkBrown

        sendVoiceButton.backgroundColor = UIColor.darkBrown
        sendVoiceButton.layer.cornerRadius = 25
        sendVoiceButton.tintColor = UIColor.background

        let menu = UIMenu(
            children: [
                UIAction(
                    title: "查看個人頁面",
                    image: UIImage(systemName: "person")) { [weak self] _ in
                        guard let self = self else { return }
                        self.goToProfile()
                },
                UIAction(
                    title: "封鎖用戶",
                    image: UIImage(systemName: "hand.raised.slash"),
                    attributes: .destructive) { [weak self] _ in
                        guard let self = self else { return }
                        self.blockUser()
                }
            ]
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), menu: menu)
    }

    private func fetchConversation() {
        guard let friend = friend else {
            return
        }
        firestoreManager.fetchConversation(with: friend.id) { [weak self] result in
            switch result {
            case .success(let conversation):
                guard let self = self, let conversation = conversation else { return }
                self.listen(to: conversation)
            case .failure(let error):
                print(error)
            }
        }
    }

    private func listen(to conversation: Conversation) {
        let docRef = FirestoreEndpoint.conversations.collectionRef.document(conversation.channelId)
        self.firestoreManager.listenDocument(docRef) { (result: Result<Conversation?, Error>) in
            switch result {
            case .success(let conversation):
                guard let conversation = conversation else { return}
                self.conversation = conversation
            case .failure(let error):
                print(error)
            }
        }
    }

    private func assembleGroupedMessages() {
        messages = []
        guard let conversation = conversation else { return }

        let groupedMessages = Dictionary(grouping: conversation.messages) { element -> DateComponents in
            let date = Calendar.current.dateComponents([.year, .month, .day], from: Date(timeIntervalSince1970: Double(element.time.seconds)))
            return date
        }

        let sortedKeys = groupedMessages.keys.sorted(by: <)
        sortedKeys.forEach { dateComponents in
            let values = groupedMessages[dateComponents]
            messages.append(values ?? [])
        }
    }

    @objc func goToProfile() {
        let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
        guard
            let publicProfileVC = storyboard.instantiateViewController(withIdentifier: String(describing: PublicProfileViewController.self))
                as? PublicProfileViewController,
            let friend = friend
        else { fatalError("Could not create publicProfileVC") }
        publicProfileVC.userId = friend.id
        navigationController?.pushViewController(publicProfileVC, animated: true)
    }

    @objc func blockUser() {
        guard let friend = friend else { return }
        let alert = UIAlertController(
            title: "封鎖\(friend.name)？",
            message: "你將不會看到他的貼文、個人檔案或來自他的訊息。你封鎖用戶時，對方不會收到通知。",
            preferredStyle: .actionSheet
        )
        let confirmAction = UIAlertAction(title: "確定封鎖", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.firestoreManager.updateUserBlocklist(userId: Constant.getUserId(), blockId: friend.id, hasBlocked: false)
            self.navigationController?.popToRootViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }

    func uploadMessage(contentType: ContentType, content: String, duration: Double = 0) {
        guard let friend = friend else { return }
        if let conversation = conversation {
            let message: [String: Any] = [
                "senderId": Constant.getUserId(),
                "content": content,
                "contentType": contentType.rawValue,
                "time": Timestamp(date: Date()),
                "duration": duration
            ]

            firestoreManager.updateConversation(channelId: conversation.channelId, message: message)
        } else {
            let document = firestoreManager.conversationsCollection.document()
            var newConversation = Conversation()
            newConversation.channelId = document.documentID
            newConversation.friendIds = [friend.id, Constant.getUserId()]
            let message = Message(
                senderId: Constant.getUserId(),
                contentType: contentType.rawValue,
                content: content,
                time: Timestamp(date: Date()),
                duration: duration
            )
            newConversation.messages = [message]
            firestoreManager.createNewConversation(newConversation, to: document)
            firestoreManager.updateUserConversation(
                userId: Constant.getUserId(),
                friendId: friend.id,
                channelId: document.documentID
            )
            listen(to: newConversation)
        }

        if !friend.blockList.contains(Constant.getUserId()) {
            let userRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
            firestoreManager.getDocument(userRef) { (result: Result<User?, Error>) in
                switch result {
                case .success(let user):
                    guard let user = user else { return }
                    let sender = PushNotificationSender()
                    sender.sendPushNotification(
                        to: friend.fcmToken,
                        title: "好享煮飯",
                        body: "\(user.name)\(contentType.getMessageBody())"
                    )
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    // MARK: - Image Message
    @IBAction func presentPHPicker(_ sender: UIButton) {
        hideAudioRecordView()
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true)
    }

    // MARK: - Location Message
    @IBAction func sendLocation(_ sender: UIButton) {
        hideAudioRecordView()
        startLocationServices()
    }

    func startLocationServices() {
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()

        switch locationAuthorizationStatus {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationManager.startUpdatingLocation()
            alertSendingLocation()
        case .restricted, .denied:
            alertLocationAccessNeeded()
        @unknown default:
            print("@unknown default")
        }
    }

    func alertSendingLocation() {
        let alert = UIAlertController(title: "是否傳送目前位置？", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constant.confirm, style: .default) { _ in
            let locationString = "\(self.location.coordinate.latitude),\(self.location.coordinate.longitude)"
            self.uploadMessage(contentType: .location, content: locationString)
        }
        let cancelAction = UIAlertAction(title: Constant.cancel, style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    func alertLocationAccessNeeded() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else { return }

        let alert = UIAlertController(
            title: "您的定位服務目前設為關閉",
            message: "您可以前往設定頁面，並選擇「使用 App 期間」來允許好享煮飯取用您的位置。",
            preferredStyle: .alert
        )
        let allowAction = UIAlertAction(
            title: "前往設定頁面",
            style: .cancel) { _ in
                UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }
        alert.addAction(UIAlertAction(title: "不用了，謝謝", style: .default))
        alert.addAction(allowAction)

        present(alert, animated: true)
    }

    // MARK: - Audio Message
    @IBAction func showRecordView(_ sender: UIButton) {
        playAndPauseButton.isHidden = true
        wrapperViewBottomConstraint.isActive = false
        wrapperViewBottomConstraint = wrapperView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        wrapperViewBottomConstraint.isActive = true

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { self.view.layoutIfNeeded() }

        guard let lastSection = messages.last else { return }
        let indexPath = IndexPath(row: lastSection.count - 1, section: messages.count - 1)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    @objc func hideAudioRecordView() {
        inputTextField.resignFirstResponder()
        playAndPauseButton.isHidden = true
        sendVoiceButton.isHidden = true
        wrapperViewBottomConstraint.isActive = false
        wrapperViewBottomConstraint = wrapperView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        wrapperViewBottomConstraint.isActive = true

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { self.view.layoutIfNeeded() }
    }

    @IBAction func recordButtonAction(_ sender: UIButton) {
        if audioRecorder == nil {
            playAndPauseButton.isHidden = true
            numOfRecorder += 1

            let destinationUrl = getDirectoryPath().appendingPathComponent("\(numOfRecorder).m4a")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            do {
                recordButton.setImage(UIImage(systemName: "square.fill"), for: .normal)
                audioRecorder = try AVAudioRecorder(url: destinationUrl, settings: settings)
                audioRecorder.record()
            } catch {
                print("Record error:", error.localizedDescription)
            }
        } else {
            audioRecorder.stop()
            audioRecorder = nil

            // save file name of record data in tableview
            UserDefaults.standard.set(numOfRecorder, forKey: "myNumber")
            playAndPauseButton.isHidden = false
            playAndPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

            recordButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            sendVoiceButton.isHidden = false
        }
    }

    @IBAction func playOrSendRecord(_ sender: UIButton) {
        let recordFilePath = getDirectoryPath().appendingPathComponent("\(numOfRecorder).m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordFilePath)
            audioPlayer.volume = 1
        } catch {
            print("Play error:", error.localizedDescription)
        }

        if !playingRecord {
            audioPlayer.play()
            timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(updatePlayingButton),
                userInfo: nil,
                repeats: true
            )
            playAndPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)

            playingRecord = true
        } else {
            timer?.invalidate()
            timer = nil
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            playAndPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

            playingRecord = false
        }
    }

    @IBAction func sendVoiceMessage(_ sender: UIButton) {
        sendVoiceButton.isHidden = true
        playAndPauseButton.isHidden = true
        playAndPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

        let recordFilePath = getDirectoryPath().appendingPathComponent("\(numOfRecorder).m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordFilePath)
        } catch {
            print("Play error:", error.localizedDescription)
        }
        print("duration \(audioPlayer.duration)")

        firestoreManager.handleAudioSendWith(url: recordFilePath) { result in
            switch result {
            case .success(let url):
                self.uploadMessage(contentType: .voice, content: url.absoluteString, duration: self.audioPlayer.duration.rounded(.up))
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc func updatePlayingButton() {
        if audioPlayer.isPlaying {
            playAndPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playAndPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

            timer?.invalidate()
            timer = nil
        }
    }

    func getDirectoryPath() -> URL {
        // create document folder url
        let fileDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return fileDirectoryURL
    }

    func configRecordSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { permissionAllowed in
                if permissionAllowed {
                    // do nothing
                } else {
                    // failed to record!
                }
            }
        } catch {
            print("Session error:", error.localizedDescription)
        }
    }
}

extension ChatRoomViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.section][indexPath.row]
        if message.senderId == Constant.getUserId() {
            switch message.contentType {
            case Constant.text:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: MineMessageCell.identifier, for: indexPath)
                    as? MineMessageCell
                else { fatalError("could not craete MineMessageCell") }
                cell.layoutCell(with: message)
                return cell
            case Constant.image:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: MineImageCell.identifier, for: indexPath)
                    as? MineImageCell
                else { fatalError("could not craete MineMessageCell") }
                cell.viewController = self
                cell.largeImageView.hero.id = "\(indexPath.section)\(indexPath.row)"
                cell.layoutCell(with: message)
                return cell
            case Constant.location:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: MineLocationCell.identifier, for: indexPath)
                    as? MineLocationCell
                else { fatalError("could not craete MineMessageCell") }
                cell.layoutCell(with: message)
                return cell
            default:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: MineVoiceCell.identifier, for: indexPath)
                    as? MineVoiceCell
                else { fatalError("could not craete MineMessageCell") }
                cell.layoutCell(with: message)
                return cell
            }
        } else {
            guard let friend = friend else { fatalError("Empty friend") }
            switch message.contentType {
            case Constant.text:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: OthersMessageCell.identifier, for: indexPath)
                    as? OthersMessageCell
                else { fatalError("could not craete MineMessageCell") }
                cell.layoutCell(with: message, friendImageURL: friend.imageURL)
                return cell
            case Constant.image:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: OtherImageCell.identifier, for: indexPath)
                    as? OtherImageCell
                else { fatalError("could not craete MineMessageCell") }
                cell.layoutCell(with: message, friendImageURL: friend.imageURL)
                cell.viewController = self
                cell.largeImageView.hero.id = "\(indexPath.section)\(indexPath.row)"
                return cell
            case Constant.location:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: OtherLocationCell.identifier, for: indexPath)
                    as? OtherLocationCell
                else { fatalError("could not craete MineMessageCell") }
                cell.layoutCell(with: message, friendImageURL: friend.imageURL)
                return cell
            default:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: OtherVoiceCell.identifier, for: indexPath)
                    as? OtherVoiceCell
                else { fatalError("could not craete MineMessageCell") }
                cell.layoutCell(with: message, friendImageURL: friend.imageURL)
                return cell
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ChatRoomViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        if !results.isEmpty,
            let result = results.first {
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

extension ChatRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let conversation = conversation else { return UIView() }

        let groupedMessages = Dictionary(grouping: conversation.messages) { element -> DateComponents in
            let date = Calendar.current.dateComponents([.year, .month, .day], from: Date(timeIntervalSince1970: Double(element.time.seconds)))
            return date
        }

        let sortedKeys = groupedMessages.keys.sorted(by: <)
        guard
            let year = sortedKeys[section].year,
            let month = sortedKeys[section].month,
            let day = sortedKeys[section].day
        else { fatalError("Wrong sorted keys") }

        let label = DateHeaderLabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.darkBrown
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(year)/\(month)/\(day)"
        let containerView = UIView()

        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        return containerView
    }
}

extension ChatRoomViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            alertLocationAccessNeeded()
        @unknown default:
            print("@unknown default")
        }
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

extension ChatRoomViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard
            let text = textField.text,
            !text.isEmpty
        else { return true }
        textField.text = nil
        uploadMessage(contentType: .text, content: text, duration: 0)
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        hideAudioRecordView()
        return true
    }
}
