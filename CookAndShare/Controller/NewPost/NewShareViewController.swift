//
//  NewShareViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import SPAlert

class NewShareViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let firestoreManager = FirestoreManager.shared
    var share = Share()
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "發布",
            style: .plain,
            target: self,
            action: #selector(post(_:))
        )

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
    }

    @IBAction func post(_ sender: UIButton) {
        if !canPost() {
            let alert = UIAlertController(
                title: "請檢查是否有欄位空白！",
                message: nil,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "了解", style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: true)
        } else {
            let alertView = SPAlertView(message: "上傳成功\n謝謝你拯救美食")
            alertView.duration = 1.3
            alertView.present(haptic: .warning) {
                self.navigationController?.popViewController(animated: true)
            }
            if share.shareId.isEmpty {
                let document = FirestoreEndpoint.shares.collectionRef.document()
                let authorRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
                share.postTime = Timestamp(date: Date())
                share.shareId = document.documentID
                share.authorId = Constant.getUserId()
                firestoreManager.setData(share, to: document)
                firestoreManager.arrayUnionString(
                    docRef: authorRef,
                    field: Constant.sharesId,
                    value: document.documentID
                )
            } else {
                try? FirestoreEndpoint.shares.collectionRef.document(share.shareId).setData(from: share, merge: true)
            }
        }
    }

    func canPost() -> Bool {
        if share.imageURL.isEmpty || share.title.isEmpty || share.description.isEmpty || share.meetTime.isEmpty || share.meetPlace.isEmpty {
            return false
        } else {
            return true
        }
    }
}

extension NewShareViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: NewShareCell.identifier, for: indexPath)
            as? NewShareCell
        else { fatalError("Could not create new share cell") }
        cell.setUpView()
        cell.layoutCell(with: share)
        cell.delegate = self
        cell.completion = { [weak self] data in
            guard let self = self else { return }
            self.share.title = data.title
            self.share.description = data.description
            self.share.meetTime = data.meetTime
            self.share.meetPlace = data.meetPlace
            self.share.bestBefore = data.bestBeforeDate
            self.share.dueDate = data.dueDate
        }
        return cell
    }
}

// MARK: - NewShareCellDelegate
extension NewShareViewController: NewShareCellDelegate {
    func willPickImage() {
        let cameraHandler: AlertActionHandler =  { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true)
        }

        let photoLibraryHandler: AlertActionHandler = { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }

        presentImagePickerAlert(camaraHandler: cameraHandler, photoLibraryHandler: photoLibraryHandler)
    }
}

extension NewShareViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard
            let userPickedImage = info[.editedImage] as? UIImage,
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewShareCell
        else { fatalError("Wrong cell") }

        // Upload photo
        self.firestoreManager.uploadPhoto(image: userPickedImage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                print(url)
                self.share.imageURL = url.absoluteString
            case .failure(let error):
                print(error)
            }
        }

        // update image
        DispatchQueue.main.async {
            cell.foodImage.image = userPickedImage
        }
        dismiss(animated: true)
    }
}
