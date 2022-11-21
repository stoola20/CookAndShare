//
//  ProfileViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit
import FirebaseAuth

enum ProfileCategory: String, CaseIterable {
    case save = "我的收藏"
    case shoppingList = "採買清單"
    case myPost = "我的貼文"
    case block = "封鎖名單"
    case deleteAccount = "刪除帳號"
    case logout = "登出"
}

class ProfileViewController: UIViewController {
    lazy var selectedBackground: UIView = {
        let background = UIView()
        background.backgroundColor = .white
        return background
    }()
    var user: User? {
        didSet {
            tableView.reloadData()
        }
    }
    let firestoreManager = FirestoreManager.shared
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        title = "個人"

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

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firestoreManager.fetchUserData(userId: Constant.getUserId()) { result in
            switch result {
            case .success(let user):
                self.user = user
            case .failure(let error):
                print(error)
            }
        }
    }

    func setUpTableView () {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor.lightOrange
        tableView.selectionFollowsFocus = false
        tableView.registerCellWithNib(identifier: ProfileUserCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: ProfileListCell.identifier, bundle: nil)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : ProfileCategory.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileUserCell.identifier, for: indexPath)
                as? ProfileUserCell,
                let user = user
            else { return UITableViewCell() }
            cell.delegate = self
            cell.selectedBackgroundView = selectedBackground
            cell.layoutCell(with: user)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileListCell.identifier, for: indexPath)
                as? ProfileListCell
            else { fatalError("Could not create list cell") }
            cell.layoutCell(in: ProfileCategory.allCases[indexPath.row])
            cell.selectedBackgroundView = selectedBackground
            return cell
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        switch indexPath.item {
        case 0:
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let savedRecipeVC = storyboard.instantiateViewController(withIdentifier: String(describing: SavedRecipeViewController.self))
                as? SavedRecipeViewController,
                let user = user
            else { fatalError("Could not instantiate ShoppingListViewController") }
            savedRecipeVC.savedRecipsId = user.savedRecipesId
            navigationController?.pushViewController(savedRecipeVC, animated: true)
        case 1:
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let shoppingListVC = storyboard.instantiateViewController(withIdentifier: String(describing: ShoppingListViewController.self))
                as? ShoppingListViewController
            else { fatalError("Could not instantiate ShoppingListViewController") }
            navigationController?.pushViewController(shoppingListVC, animated: true)
        case 2:
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let publicProfileVC = storyboard.instantiateViewController(
                    withIdentifier: String(describing: PublicProfileViewController.self)
                )
                as? PublicProfileViewController
            else { fatalError("Could not create publicProfileVC") }
            publicProfileVC.userId = Constant.getUserId()
            navigationController?.pushViewController(publicProfileVC, animated: true)
        case 3:
            print("封鎖名單")
        case 4:
            print("刪除帳號")
        default:
            firestoreManager.updateFCMToken(userId: Constant.getUserId(), fcmToken: "")
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }

            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                    as? LoginViewController
            else { fatalError("Could not instantiate LoginViewController") }
            loginVC.tabBarItem = UITabBarItem(title: "個人", image: UIImage(systemName: "person.circle"), tag: 3)
            var arrayChildViewControllers = self.tabBarController?.viewControllers
            if let selectedTabIndex = tabBarController?.selectedIndex {
                arrayChildViewControllers?.replaceSubrange(selectedTabIndex...selectedTabIndex, with: [loginVC])
            }
            self.tabBarController?.viewControllers = arrayChildViewControllers
        }
    }
}

extension ProfileViewController: ProfileUserCellDelegate {
    func willEditName() {
        let alert = UIAlertController(title: "請輸入暱稱", message: nil, preferredStyle: .alert)
        alert.addTextField()
        let okAction = UIAlertAction(title: Constant.confirm, style: .default) { _ in
            guard
                let name = alert.textFields?[0].text,
                !name.isEmpty,
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileUserCell
            else { return }
            self.firestoreManager.updateUserName(userId: Constant.getUserId(), name: name)
            cell.userName.text = name
        }
        let cancelAction = UIAlertAction(title: Constant.cancel, style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    func willChangePhoto() {
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard
            let userPickedImage = info[.editedImage] as? UIImage,
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileUserCell
        else { fatalError("Wrong cell") }

        // Upload photo
        self.firestoreManager.uploadPhoto(image: userPickedImage) { result in
            switch result {
            case .success(let url):
                print(url)
                self.firestoreManager.updateUserPhoto(userId: Constant.getUserId(), imageURL: url.absoluteString)
            case .failure(let error):
                print(error)
            }
        }

        // update image
        DispatchQueue.main.async {
            cell.profileImageView.image = userPickedImage
        }
        dismiss(animated: true)
    }
}
