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

class ShareViewController: UIViewController {
    let firestoreManager = FirestoreManager.shared
    var shares: [Share] = []
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
                image: UIImage(systemName: "message"),
                style: .plain,
                target: self,
                action: #selector(showMessage)
            ),
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

        tableView.es.addPullToRefresh(animator: header) { [weak self] in
            guard let self = self else { return }
            self.fetchSharePost()
        }
        tableView.es.startPullToRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if fromPublicVC { return }
        fetchSharePost()
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.lightOrange
        tableView.registerCellWithNib(identifier: ShareCell.identifier, bundle: nil)
    }

    func fetchSharePost() {
        firestoreManager.fetchSharePost { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let shares):
                self.shares = shares
                self.shares.sort { $0.postTime.seconds > $1.postTime.seconds }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.es.stopPullToRefresh()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc func addShare() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                    as? LoginViewController
            else { fatalError("Could not create loginVC") }
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

    @objc func showMessage() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                    as? LoginViewController
            else { fatalError("Could not create loginVC") }
            present(loginVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
            guard
                let chatListVC = storyboard.instantiateViewController(
                    withIdentifier: String(describing: ChatListViewController.self)
                )
                    as? ChatListViewController
            else { fatalError("Could not create ChatListViewController") }
            navigationController?.pushViewController(chatListVC, animated: true)
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
        cell.foodImageView.hero.id = "\(indexPath.section)\(indexPath.row)"
        cell.delegate = self
        cell.layoutCell(with: shares[indexPath.row])
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
}
