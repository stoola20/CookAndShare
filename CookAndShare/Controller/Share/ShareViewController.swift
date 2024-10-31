//
//  ShareViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Hero
import ESPullToRefresh
import SPAlert

class ShareViewController: UIViewController {
    var shareId = ""
    var fromPublicVC = false
    private let firestoreManager = FirestoreManager.shared
    private var authorDict: [String: User] = [:]
    private let group = DispatchGroup()
    private var shares: [Share] = [] {
        didSet {
            shares.forEach { share in
                group.enter()
                let docRef = FirestoreEndpoint.users.collectionRef.document(share.authorId)
                firestoreManager.getDocument(docRef) { [weak self] (result: Result<User?, Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let author):
                        guard let author = author else { return }
                        self.authorDict[author.id] = author
                    case .failure(let error):
                        print(error)
                    }
                    self.group.leave()
                }
            }

            group.notify(queue: DispatchQueue.main) { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.tableView.es.stopPullToRefresh()
            }
        }
    }
    private var header: ESRefreshHeaderAnimator {
        let header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        header.pullToRefreshDescription = "下拉更新"
        header.releaseToRefreshDescription = ""
        header.loadingDescription = "載入中..."
        return header
    }

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "食物分享"
        setUpTableView()
        setUpNavBar()

        if !fromPublicVC {
            tableView.es.addPullToRefresh(animator: header) { [weak self] in
                guard let self = self else { return }
                self.fetchSharePost()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !fromPublicVC {
            fetchSharePost()
        } else {
            getShare(by: shareId)
        }
    }

    // MARK: - Private methods
    private func setUpTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.lightOrange
        tableView.registerCellWithNib(identifier: ShareCell.identifier, bundle: nil)
    }

    private func setUpNavBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "plus.circle"),
                style: .plain,
                target: self,
                action: #selector(addShare)
            )
        ]

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
    }

    private func fetchSharePost() {
        if Auth.auth().currentUser == nil {
            let query = FirestoreEndpoint.shares.collectionRef
            getShares(query: query)
        } else {
            let userRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
            firestoreManager.getDocument(userRef) { [weak self] (result: Result<User?, Error>) in
                switch result {
                case .success(let user):
                    guard let self = self, let user = user else { return }

                    let query = user.blockList.isEmpty
                    ? FirestoreEndpoint.shares.collectionRef
                    : FirestoreEndpoint.shares.collectionRef.whereField(Constant.authorId, notIn: user.blockList)

                    self.getShares(query: query)
                case .failure(let error):
                    AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
                }
            }
        }
    }

    private func getShares(query: Query) {
        group.enter()
        firestoreManager.getDocuments(query) { [weak self] (result: Result<[Share], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let shares):
                self.deleteExpiredShare(from: shares, manager: self.firestoreManager)
            case .failure(let error):
                AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
            }
            self.group.leave()
        }
    }

    private func getShare(by id: String) {
        let docRef = FirestoreEndpoint.shares.collectionRef.document(id)
        group.enter()
        firestoreManager.getDocument(docRef) { [weak self] (result: Result<Share?, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let share):
                guard let share = share else { return }
                self.shares = [share]
            case .failure(let error):
                AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
            }
            self.group.leave()
        }
    }

    private func deleteExpiredShare(from shares: [Share], manager: FirestoreManager) {
        var tempShares: [Share] = []
        shares.forEach { share in
            let bbfTimeInterval = Double(share.bestBefore.seconds)
            let shareDayComponent = Calendar.current.component(
                .day,
                from: Date(timeIntervalSince1970: bbfTimeInterval)
            )
            let today = Calendar.current.component(.day, from: Date())
            if bbfTimeInterval < Date().timeIntervalSince1970 && shareDayComponent != today {
                let shareRef = FirestoreEndpoint.shares.collectionRef.document(share.shareId)
                let userRef = FirestoreEndpoint.users.collectionRef.document(share.authorId)
                manager.deleteDocument(docRef: shareRef)
                manager.arrayRemoveString(
                    docRef: userRef,
                    field: Constant.sharesId,
                    value: share.shareId
                )
            } else {
                tempShares.append(share)
            }
        }
        self.shares = tempShares.sorted { $0.postTime.seconds > $1.postTime.seconds }
    }

    // MARK: - Action
    @objc func addShare() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard let loginVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: LoginViewController.self)
            ) as? LoginViewController
            else { fatalError("Could not create loginVC") }
            loginVC.isPresented = true
            present(loginVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: Constant.newpost, bundle: nil)
            guard
                let newShareVC = storyboard.instantiateViewController(
                    withIdentifier: String(describing: NewShareViewController.self)
                )
                    as? NewShareViewController
            else { fatalError("Could not create newShareVC") }
            navigationController?.pushViewController(newShareVC, animated: true)
        }
    }
}

extension ShareViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shares.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ShareCell.identifier, for: indexPath)
            as? ShareCell
        else { fatalError("Could not create share cell") }
        let share = shares[indexPath.row]
        guard let author = authorDict[share.authorId] else { fatalError("Failed to fetch author") }
        cell.foodImageView.hero.id = "\(indexPath.section)\(indexPath.row)"
        cell.delegate = self
        cell.layoutCell(with: share, author: author)
        return cell
    }
}

extension ShareViewController: ShareCellDelegate {
    func goToProfile(_ userId: String) {
        let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
        guard
            let publicProfileVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: PublicProfileViewController.self)
            )
            as? PublicProfileViewController
        else { fatalError("Could not create publicProfileVC") }
        publicProfileVC.userId = userId
        navigationController?.pushViewController(publicProfileVC, animated: true)
    }

    func presentLargePhoto(url: String, heroId: String) {
        let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
        guard let previewVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: PreviewViewController.self)
        ) as? PreviewViewController
        else { fatalError("Could not create previewVC") }
        previewVC.imageURL = url
        previewVC.heroId = heroId
        previewVC.modalPresentationStyle = .overFullScreen
        present(previewVC, animated: true)
    }

    func deletePost(_ cell: ShareCell) {
        let handler: AlertActionHandler = { [weak self] _ in
            guard let self = self, let indexPath = self.tableView.indexPath(for: cell)
            else { fatalError("Wrong indexPath") }

            let share = self.shares[indexPath.row]
            self.shares.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)

            let shareRef = FirestoreEndpoint.shares.collectionRef.document(share.shareId)
            let userRef = FirestoreEndpoint.users.collectionRef.document(share.authorId)
            self.firestoreManager.deleteDocument(docRef: shareRef)
            self.firestoreManager.arrayRemoveString(
                docRef: userRef,
                field: Constant.sharesId,
                value: share.shareId
            )
        }

        presentAlertWith(
            alertTitle: "確定刪除此貼文？",
            alertMessage: "此動作將無法回復。",
            confirmTitle: "確定刪除",
            cancelTitle: "取消",
            handler: handler
        )
    }

    func editPost(_ cell: ShareCell) {
        let storyboard = UIStoryboard(name: Constant.newpost, bundle: nil)
        guard
            let newShareVC = storyboard.instantiateViewController(withIdentifier: String(describing: NewShareViewController.self))
                as? NewShareViewController,
            let indexPath = self.tableView.indexPath(for: cell)
        else { fatalError("Could not instantiate newShareVC") }
        newShareVC.share = shares[indexPath.row]
        navigationController?.pushViewController(newShareVC, animated: true)
    }

    func block(user: User) {
        let handler: AlertActionHandler = { [weak self] _ in
            guard let self = self else { return }

            let myRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
            self.firestoreManager.arrayUnionString(
                docRef: myRef,
                field: Constant.blockList,
                value: user.id
            )
        }

        presentAlertWith(
            alertTitle: "封鎖\(user.name)？",
            alertMessage: "你將不會看到他的貼文、個人檔案或來自他的訊息。你封鎖用戶時，對方不會收到通知。",
            confirmTitle: "確定封鎖",
            cancelTitle: "取消",
            handler: handler
        )
    }

    func reportShare(_ cell: ShareCell) {
        let handler: AlertActionHandler = { [weak self] _ in
            guard let self = self, let indexPath = self.tableView.indexPath(for: cell) else { return }

            let shareRef = FirestoreEndpoint.shares.collectionRef.document(self.shares[indexPath.row].shareId)
            self.firestoreManager.arrayUnionString(
                docRef: shareRef,
                field: Constant.reports,
                value: Constant.getUserId()
            )

            AlertKitAPI.present(title: "謝謝你告知我們，我們會在未來減少顯示這類內容", style: .iOS17AppleMusic, haptic: .success)
        }

        presentAlertWith(
            alertTitle: "檢舉這則貼文？",
            alertMessage: "你的檢舉將會匿名。",
            confirmTitle: "確定檢舉",
            cancelTitle: "取消",
            handler: handler
        )
    }
}
