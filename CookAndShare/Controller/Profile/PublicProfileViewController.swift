//
//  PublicProfileViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit
import SPAlert
import FirebaseAuth

class PublicProfileViewController: UIViewController {
    var userId = String.empty
    var recipes: [Recipe] = []
    var shares: [Share] = []
    var user: User?
    var toRecipe = true
    let firestoreManager = FirestoreManager.shared
    @IBOutlet weak var recipeCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        navigationItem.backButtonTitle = ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    func setUpCollectionView() {
        recipeCollectionView.bounces = false
        recipeCollectionView.dataSource = self
        recipeCollectionView.delegate = self
        recipeCollectionView.collectionViewLayout = configureCollectionViewLayout()
        recipeCollectionView.registerCellWithNib(identifier: PublicProfileHeaderCell.identifier, bundle: nil)
        recipeCollectionView.registerCellWithNib(identifier: PublicPostCell.identifier, bundle: nil)
        recipeCollectionView.register(
            UINib(nibName: PublicPostHeaderView.reuseIdentifier, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PublicPostHeaderView.reuseIdentifier
        )
    }

    func fetchData() {
        var tempRecipes: [Recipe] = []
        var tempShares: [Share] = []
        let group = DispatchGroup()
        group.enter()
        let userRef = FirestoreEndpoint.users.collectionRef.document(userId)
        firestoreManager.getDocument(userRef) { [weak self] (result: Result<User?, Error>) in
            switch result {
            case .success(let user):
                guard let self = self, let user = user else { return }
                self.user = user
                user.recipesId.forEach { recipeId in
                    group.enter()
                    let docRef = FirestoreEndpoint.recipes.collectionRef.document(recipeId)
                    self.firestoreManager.getDocument(docRef) { (result: Result<Recipe?, Error>) in
                        switch result {
                        case .success(let recipe):
                            guard let recipe = recipe else { return }
                            tempRecipes.append(recipe)
                        case .failure(let error):
                            AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
                            
                        }
                        group.leave()
                    }
                }
                user.sharesId.forEach { shareId in
                    group.enter()
                    let docRef = FirestoreEndpoint.shares.collectionRef.document(shareId)
                    self.firestoreManager.getDocument(docRef) { (result: Result<Share?, Error>) in
                        switch result {
                        case .success(let share):
                            guard let share = share else { return }
                            tempShares.append(share)
                        case .failure(let error):
                            AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
                        }
                        group.leave()
                    }
                }
            case .failure(let error):
                print(error)
            }
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            self.recipes = tempRecipes.sorted { $0.time.seconds > $1.time.seconds }
            self.shares = tempShares.sorted { $0.postTime.seconds > $1.postTime.seconds }
            self.recipeCollectionView.reloadData()
        }
    }
}

extension PublicProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = user else { return 0 }
        if section == 0 {
            return 1
        } else {
            return toRecipe ? user.recipesId.count : user.sharesId.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let user = user else { return UICollectionViewCell() }
        if indexPath == IndexPath(item: 0, section: 0) {
            guard
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicProfileHeaderCell.identifier, for: indexPath)
                as? PublicProfileHeaderCell
            else { fatalError("Could not create PublicProfileHeaderCell") }
            cell.delegate = self
            cell.layoutCell(with: user)
            return cell
        } else {
            guard
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicPostCell.identifier, for: indexPath)
                as? PublicPostCell
            else { fatalError("Could not create PublicPostCell") }
            if toRecipe {
                cell.mainImageView.loadImage(
                    self.recipes[indexPath.item].mainImageURL,
                    placeHolder: UIImage(named: "friedRice")
                )
            } else {
                cell.mainImageView.loadImage(
                    self.shares[indexPath.item].imageURL,
                    placeHolder: UIImage(named: "friedRice")
                )
            }
            return cell
        }
    }
}

extension PublicProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if toRecipe {
                let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
                guard
                    let detailRecipeVC = storyboard.instantiateViewController(withIdentifier: String(describing: DetailRecipeViewController.self))
                        as? DetailRecipeViewController
                else { fatalError("Could not create detailVC") }
                detailRecipeVC.recipeId = recipes[indexPath.item].recipeId
                navigationController?.pushViewController(detailRecipeVC, animated: true)
            } else {
                let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
                guard
                    let shareVC = storyboard.instantiateViewController(withIdentifier: String(describing: ShareViewController.self))
                        as? ShareViewController
                else { fatalError("Could not create detailVC") }
                shareVC.shareId = shares[indexPath.item].shareId
                shareVC.fromPublicVC = true
                navigationController?.pushViewController(shareVC, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PublicPostHeaderView.identifier,
            for: indexPath) as? PublicPostHeaderView
        else { fatalError("Could not create new post header view") }
        headerView.delegate = self
        return headerView
    }
}

extension PublicProfileViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                return NSCollectionLayoutSection(group: group)

            default:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1 / 3))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
                section.boundarySupplementaryItems = [sectionHeader]

                return section
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension PublicProfileViewController: PublicPostHeaderViewDelegate {
    func headerViewDidChange(toRecipe: Bool) {
        self.toRecipe = toRecipe
        self.recipeCollectionView.reloadData()
    }
}

extension PublicProfileViewController: PublicProfileHeaderCellDelegate {
    func presentChatRoom() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                    as? LoginViewController
            else { fatalError("Could not create loginVC") }
            loginVC.isPresented = true
            present(loginVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
            guard
                let chatRoomVC = storyboard.instantiateViewController(withIdentifier: String(describing: ChatRoomViewController.self))
                    as? ChatRoomViewController,
                let user = user
            else { fatalError("Could not instantiate chatRoomVC") }
            chatRoomVC.title = user.name
            chatRoomVC.friend = user
            navigationController?.pushViewController(chatRoomVC, animated: true)
        }
    }

    func blockUser() {
        guard let user = user, Auth.auth().currentUser != nil else {
            // 若沒登入，無法封鎖
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            if let loginVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: LoginViewController.self)
            ) as? LoginViewController {
                loginVC.isPresented = true
                present(loginVC, animated: true)
            }
            return
        }

        let handler: AlertActionHandler = { [weak self] _ in
            guard let self = self else { return }
            let myRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
            self.firestoreManager.arrayUnionString(
                docRef: myRef,
                field: Constant.blockList,
                value: user.id
            )
            self.navigationController?.popToRootViewController(animated: true)
        }

        presentAlertWith(
            alertTitle: "封鎖\(user.name)？",
            alertMessage: "你將不會看到他的貼文、個人檔案或來自他的訊息。你封鎖用戶時，對方不會收到通知。",
            confirmTitle: "確定封鎖",
            cancelTitle: Constant.cancel,
            handler: handler
        )
    }
}
