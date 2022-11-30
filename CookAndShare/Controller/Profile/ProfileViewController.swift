//
//  ProfileViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SafariServices
import KeychainSwift
import Alamofire
import SwiftJWT
import SPAlert
import AuthenticationServices

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
    var user: User?
    var allUsers: [User] = []
    private let firestoreManager = FirestoreManager.shared
    private let coredataManager = CoreDataManager.shared
    private let imagePicker = UIImagePickerController()
    private var userName = ""
    private var currentNonce: String?

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

        let action = UIAction(
            title: "隱私權政策",
            image: UIImage(systemName: "checkmark.shield")
        ) { [weak self] _ in
            guard
                let url = URL(string: "https://www.privacypolicies.com/live/32b90ff9-1e31-4d0b-bb08-7ca320c11db9"),
                let self = self
            else { return }

            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "checkmark.shield"),
            primaryAction: action
        )

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
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

    func revokeToken(clientSecret: String, token: String) {
        let paramString: [String: Any] = [
            "client_id": JWTManager.shared.bundleId,
            "client_secret": clientSecret,
            "token": token,
            "token_type_hint": "refresh_token"
        ]

        let headers: HTTPHeaders = [.contentType("application/x-www-form-urlencoded")]

        guard let url = URL(string: JWTManager.shared.revokeEndpoint) else { return }
        AF.request(
            url,
            method: .post,
            parameters: paramString,
            headers: headers
        )
        .responseData { response in
            print("===revoke status code \(String(describing: response.response?.statusCode))")
        }
    }

    func showLoginVC() {
        let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
        guard
            let messageLoginVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: LoginViewController.self)
            )
                as? LoginViewController,
            let profileLoginVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: LoginViewController.self)
            )
            as? LoginViewController
        else { fatalError("Could not instantiate LoginViewController") }
        messageLoginVC.tabBarItem = UITabBarItem(
            title: "訊息",
            image: UIImage(named: "chat_gray_25"),
            selectedImage: UIImage(named: "chat_25")
        )
        profileLoginVC.tabBarItem = UITabBarItem(
            title: "個人",
            image: UIImage(named: "account_gray_25"),
            selectedImage: UIImage(named: "account_25")
        )
        var childViewControllers = self.tabBarController?.viewControllers
        childViewControllers?.replaceSubrange(2...2, with: [messageLoginVC])
        childViewControllers?.replaceSubrange(4...4, with: [profileLoginVC])
        self.tabBarController?.viewControllers = childViewControllers
        UserDefaults.standard.set(false, forKey: "normalAppearance")
    }

    func deleteAccount() {
        let alert = UIAlertController(
            title: "永久刪除帳號？",
            message: "此步驟無法回復。如果繼續，你的個人檔案、發文、訊息記錄都將被刪除，他人將無法在好享煮飯看到你。基於安全性，你將需要重新登入。",
            preferredStyle: .actionSheet
        )

        let confirmAction = UIAlertAction(title: "確認刪除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.signInWithApple()
            self.firestoreManager.fetchUserData(userId: Constant.getUserId()) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    print(error)
                }
            }
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

    func deleteFirestoreDocument() {
        guard let mySelf = self.user else { return }
        self.firestoreManager.searchAllUsers { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                users.forEach { otherOne in
                    self.firestoreManager.usersCollection.document(otherOne.id).updateData([
                        "blockList": FieldValue.arrayRemove([mySelf.id])
                    ])
                    mySelf.conversationId.forEach { channelId in
                        if otherOne.conversationId.contains(channelId) {
                            self.firestoreManager.usersCollection.document(otherOne.id).updateData([
                                Constant.conversationId: FieldValue.arrayRemove([channelId])
                            ])
                        }
                    }
                    mySelf.recipesId.forEach { recipeId in
                        if otherOne.savedRecipesId.contains(recipeId) {
                            self.firestoreManager.usersCollection.document(otherOne.id).updateData([
                                Constant.savedRecipesId: FieldValue.arrayRemove([recipeId])
                            ])
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        mySelf.conversationId.forEach { channelId in
            self.firestoreManager.conversationsCollection.document(channelId).delete()
        }
        mySelf.sharesId.forEach { shareId in
            self.firestoreManager.sharesCollection.document(shareId).delete()
        }
        mySelf.recipesId.forEach { recipeId in
            self.firestoreManager.recipesCollection.document(recipeId).delete()
        }

        self.firestoreManager.usersCollection.document(mySelf.id).delete()
    }

    func deleteCoreData() {
        guard let shoppingList = coredataManager.fetchItem() else {
            return
        }
        shoppingList.forEach { item in
            coredataManager.deleteItem(item: item)
        }
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
                as? ProfileUserCell
            else { fatalError("Could not create user cell") }

            cell.delegate = self
            cell.selectedBackgroundView = selectedBackground
            firestoreManager.fetchUserData(userId: Constant.getUserId()) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let user):
                    self.user = user
                    self.userName = user.name
                    cell.layoutCell(with: user)
                case .failure(let error):
                    print(error)
                }
            }
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
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 { return }
        switch indexPath.item {
        case 0:
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let savedRecipeVC = storyboard.instantiateViewController(withIdentifier: String(describing: SavedRecipeViewController.self))
                as? SavedRecipeViewController
            else { fatalError("Could not instantiate ShoppingListViewController") }
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
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let blockListVC = storyboard.instantiateViewController(withIdentifier: String(describing: BlockListViewController.self))
                    as? BlockListViewController
            else { fatalError("Could not instantiate blockListVC") }
            navigationController?.pushViewController(blockListVC, animated: true)
        case 4:
            deleteAccount()
        default:
            firestoreManager.updateFCMToken(userId: Constant.getUserId(), fcmToken: "")
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            showLoginVC()
        }
    }
}

extension ProfileViewController: ProfileUserCellDelegate {
    func willEditName() {
        let editNameAlert = UIAlertController(title: "編輯暱稱", message: nil, preferredStyle: .alert)
        editNameAlert.addTextField { [weak self] textField in
            guard let self = self else { return }
            textField.text = self.userName
        }
        let okAction = UIAlertAction(title: Constant.confirm, style: .default) { [weak self] _ in
            guard
                let self = self,
                let name = editNameAlert.textFields?[0].text,
                !name.isEmpty,
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileUserCell
            else { return }
            self.firestoreManager.updateUserName(userId: Constant.getUserId(), name: name)
            cell.userName.text = name
            self.userName = name
        }
        let cancelAction = UIAlertAction(title: Constant.cancel, style: .cancel, handler: nil)
        editNameAlert.addAction(okAction)
        editNameAlert.addAction(cancelAction)
        present(editNameAlert, animated: true, completion: nil)
    }

    func willChangePhoto() {
        let controller = UIAlertController(title: "請選擇照片來源", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "相機", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "相簿", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cameraAction)
        controller.addAction(photoLibraryAction)
        controller.addAction(cancelAction)

        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

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
        self.firestoreManager.uploadPhoto(image: userPickedImage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                print(url)
                self.firestoreManager.updateUserPhoto(userId: Constant.getUserId(), imageURL: url.absoluteString)
                cell.profileImageView.loadImage(url.absoluteString)
            case .failure(let error):
                print(error)
            }
        }
        dismiss(animated: true)
    }
}

extension ProfileViewController: ASAuthorizationControllerDelegate {
    func signInWithApple() {
        let nonce = AuthManager.shared.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = AuthManager.shared.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        self.deleteFirestoreDocument()
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )

            let currentUser = Auth.auth().currentUser
            // Re-authenticate
            currentUser?.reauthenticate(with: credential) { [weak self] result, error in
                guard let self = self else { return }
                if let error = error {
                    // An error happened.
                    print("===error \(error)")
                } else {
                    // User re-authenticated.
                    self.deleteCoreData()

                    let keychain = KeychainSwift()
                    let token = keychain.get("refreshToken")
                    keychain.delete("refreshToken")
                    guard let token = token else { return }
                    self.revokeToken(clientSecret: JWTManager.shared.makeJWT(), token: token)
                    currentUser?.delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            print("帳戶已被 firebase auth 刪除")
                        }
                    }
                    self.showLoginVC()
                    SPAlert.present(message: "帳號已刪除", haptic: .error)
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登入失敗，處理 Error
        switch error {
        case ASAuthorizationError.canceled:
            SPAlert.present(message: "使用者取消登入", haptic: .error)
        case ASAuthorizationError.failed:
            SPAlert.present(message: "授權請求失敗", haptic: .error)
        case ASAuthorizationError.invalidResponse:
            SPAlert.present(message: "授權請求無回應", haptic: .error)
        case ASAuthorizationError.notHandled:
            SPAlert.present(message: "授權請求未處理", haptic: .error)
        case ASAuthorizationError.unknown:
            SPAlert.present(message: "授權失敗，原因不明", haptic: .error)
        default:
            break
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
// 在畫面上顯示授權畫面
extension ProfileViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
