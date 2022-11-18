//
//  NewShareViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit
import PhotosUI
import FirebaseFirestore

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
        if share.imageURL.isEmpty || share.title.isEmpty || share.description.isEmpty || share.meetTime.isEmpty || share.meetPlace.isEmpty {
            let alert = UIAlertController(
                title: "請檢查是否有欄位空白！",
                message: nil,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "了解", style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: true)
        } else {
            let document = firestoreManager.sharesCollection.document()
            share.postTime = Timestamp(date: Date())
            share.shareId = document.documentID
            share.authorId = Constant.getUserId()
            firestoreManager.addNewShare(share, to: document)
            firestoreManager.updateUserSharePost(shareId: document.documentID, userId: Constant.getUserId(), isNewPost: true)
            navigationController?.popViewController(animated: true)
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
        let controller = UIAlertController(title: "請選擇照片來源", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cameraAction)
        controller.addAction(photoLibraryAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
}

extension NewShareViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard
            let userPickedImage = info[.editedImage] as? UIImage,
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewShareCell
        else { fatalError("Wrong cell") }

        // Upload photo
        self.firestoreManager.uploadPhoto(image: userPickedImage) { result in
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
