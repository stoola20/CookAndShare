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

class ChatRoomViewController: UIViewController {
    var timer: Timer?
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numOfRecorder: Int = 0
    var playingRecord = false
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
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        guard let text = inputTextField.text else { return }
        if text.isEmpty { return }
        inputTextField.text = nil
        uploadMessage(contentType: .text, content: text)
    }

    func uploadMessage(contentType: ContentType, content: String, duration: Double = 0) {
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
                time: Timestamp(date: Date()),
                duration: duration
            )
            newConversation.messages = [message]
            self.conversation = newConversation
            firestoreManager.createNewConversation(newConversation, to: document)
            firestoreManager.updateUserConversation(userId: Constant.userId, friendId: friend.id, channelId: document.documentID)
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
            "time": Timestamp(date: Date()),
            "duration": duration
        ]
        firestoreManager.updateConversation(channelId: conversation.channelId, message: message)

        let sender = PushNotificationSender()
        sender.sendPushNotification(
            to: friend.fcmToken,
            title: friend.name,
            body: "\(friend.name)\(contentType.getMessageBody())"
        )
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
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            let alert = UIAlertController(title: "是否傳送目前位置？", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: Constant.confirm, style: .default) { _ in
                let locationString = "\(self.location.coordinate.latitude),\(self.location.coordinate.longitude)"
                self.uploadMessage(contentType: .location, content: locationString)
            }
            let cancelAction = UIAlertAction(title: Constant.cancel, style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - Audio Message
    @IBAction func showRecordView(_ sender: UIButton) {
        playAndPauseButton.isHidden = true
        wrapperViewBottomConstraint.isActive = false
        wrapperViewBottomConstraint = wrapperView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        wrapperViewBottomConstraint.isActive = true

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { self.view.layoutIfNeeded() }

        guard let conversation = conversation else {
            return
        }

        let indexPath = IndexPath(row: conversation.messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    @objc func hideAudioRecordView() {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let conversation = conversation else { return 0 }
        return conversation.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let conversation = conversation else { return UITableViewCell() }
        let message = conversation.messages[indexPath.row]
        if message.senderId == Constant.userId {
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

extension ChatRoomViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        hideAudioRecordView()
        return true
    }
}
