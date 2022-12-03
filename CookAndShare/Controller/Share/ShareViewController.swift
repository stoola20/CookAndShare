//
//  ShareViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit
import FirebaseAuth
import Hero
import ESPullToRefresh
import SPAlert

class ShareViewController: UIViewController {
    let firestoreManager = FirestoreManager.shared
    let group = DispatchGroup()
    var shares: [Share] = [] {
        didSet {
            shares.forEach { share in
                group.enter()
                self.firestoreManager.fetchUserData(userId: share.authorId) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let author):
                        self.authorDict[author.id] = author
                        self.group.leave()
                    case .failure(let error):
                        print(error)
                        self.group.leave()
                    }
                }
            }
        }
    }
    var authorDict: [String: User] = [:]
    var shareId = ""
    var fromPublicVC = false
    var header: ESRefreshHeaderAnimator {
        let header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        header.pullToRefreshDescription = "下拉更新"
        header.releaseToRefreshDescription = ""
        header.loadingDescription = "載入中..."
        return header
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "食物分享"
        setUpTableView()

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
            fetchShareById()
        }
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.lightOrange
        tableView.registerCellWithNib(identifier: ShareCell.identifier, bundle: nil)
    }

    func fetchSharePost() {
        group.enter()
        firestoreManager.fetchSharePost { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let shares):
                self.shares = shares.sorted { $0.postTime.seconds > $1.postTime.seconds }
                self.group.leave()
            case .failure(let error):
                print(error)
                self.group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.tableView.es.stopPullToRefresh()
        }
    }

    func fetchShareById() {
        group.enter()
        firestoreManager.fetchShareBy(shareId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let share):
                self.shares = [share]
                self.group.leave()
            case .failure(let error):
                print(error)
                self.group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }

    @objc func addShare() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                    as? LoginViewController
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
        guard
            let previewVC = storyboard.instantiateViewController(withIdentifier: String(describing: PreviewViewController.self))
                as? PreviewViewController
        else { fatalError("Could not create previewVC") }
        previewVC.imageURL = url
        previewVC.heroId = heroId
        previewVC.modalPresentationStyle = .overFullScreen
        present(previewVC, animated: true)
    }

    func deletePost(_ cell: ShareCell) {
        let alert = UIAlertController(title: "確定刪除此貼文？", message: "此動作將無法回復。", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確定刪除", style: .destructive) { [weak self] _ in
            guard
                let self = self,
                let indexPath = self.tableView.indexPath(for: cell)
            else { fatalError("Wrong indexPath") }
            let share = self.shares[indexPath.row]
            self.shares.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.firestoreManager.deleteSharePost(shareId: share.shareId)
            self.firestoreManager.updateUserSharePost(shareId: share.shareId, userId: share.authorId, isNewPost: false)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
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
        let alert = UIAlertController(
            title: "封鎖\(user.name)？",
            message: "你將不會看到他的貼文、個人檔案或來自他的訊息。你封鎖用戶時，對方不會收到通知。",
            preferredStyle: .actionSheet
        )
        let confirmAction = UIAlertAction(title: "確定封鎖", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.firestoreManager.updateUserBlocklist(userId: Constant.getUserId(), blockId: user.id, hasBlocked: false)
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

    func reportShare(_ cell: ShareCell) {
        let alert = UIAlertController(
            title: "檢舉這則貼文？",
            message: "你的檢舉將會匿名。",
            preferredStyle: .actionSheet
        )
        let confirmAction = UIAlertAction(title: "確定檢舉", style: .destructive) { [weak self] _ in
            guard
                let self = self,
                let indexPath = self.tableView.indexPath(for: cell)
            else { return }
            self.firestoreManager.updateShareReports(shareId: self.shares[indexPath.row].shareId, userId: Constant.getUserId())
            SPAlert.present(message: "謝謝你告知我們，我們會在未來減少顯示這類內容", haptic: .success)
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
}
