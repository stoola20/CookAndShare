//
//  PublicProfileViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    func setUpCollectionView() {
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
        let group = DispatchGroup()
        group.enter()
        firestoreManager.fetchUserData(userId: userId) { result in
            switch result {
            case .success(let user):
                self.user = user
                user.recipesId.forEach { recipeId in
                    group.enter()
                    self.firestoreManager.fetchRecipeBy(recipeId) { result in
                        switch result {
                        case .success(let recipe):
                            self.recipes.append(recipe)
                            group.leave()
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                user.sharesId.forEach { shareId in
                    group.enter()
                    self.firestoreManager.fetchShareBy(shareId) { result in
                        switch result {
                        case .success(let share):
                            self.shares.append(share)
                            group.leave()
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                group.leave()
            case .failure(let error):
                print(error)
            }
        }

        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
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
                cell.mainImageView.load(url: URL(string: self.recipes[indexPath.item].mainImageURL)!)
            } else {
                cell.mainImageView.load(url: URL(string: self.shares[indexPath.item].imageURL)!)
            }
            return cell
        }
    }
}

extension PublicProfileViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/4))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                return NSCollectionLayoutSection(group: group)

            default:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3))
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

extension PublicProfileViewController: UICollectionViewDelegate {
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

extension PublicProfileViewController: PublicPostHeaderViewDelegate {
    func headerView(didChange: Bool) {
        self.toRecipe = didChange
        self.recipeCollectionView.reloadData()
    }
}

extension PublicProfileViewController: PublicProfileHeaderCellDelegate {
    func presentChatRoom() {
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
