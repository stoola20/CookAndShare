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

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "發布", style: .plain, target: self, action: #selector(post(_:)))
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
    }

    @IBAction func post(_ sender: UIButton) {
        let document = firestoreManager.sharesCollection.document()
        share.postTime = Timestamp(date: Date())
        share.shareId = document.documentID
        share.authorId = Constant.userId
        firestoreManager.addNewShare(share, to: document)
        firestoreManager.updateUserSharePost(shareId: document.documentID, userId: Constant.userId, isNewPost: true)
        navigationController?.popViewController(animated: true)
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
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension NewShareViewController: PHPickerViewControllerDelegate {
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
                            self.share.imageURL = url.absoluteString
                        case .failure(let error):
                            print(error)
                        }
                    }

                    // update image
                    DispatchQueue.main.async {
                        guard let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewShareCell
                        else { fatalError("Wrong cell") }
                        cell.foodImage.image = image
                    }
                }
            }
        }
    }
}
