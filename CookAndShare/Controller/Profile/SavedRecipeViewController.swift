//
//  SavedRecipeViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit
import SPAlert

class SavedRecipeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var alertStackView: UIStackView!
    @IBOutlet weak var seeRecipeButton: UIButton!
    let firestoreManager = FirestoreManager.shared
    var user: User?
    var savedRecipes: [Recipe] = []
    var savedRecipsId: [String] = [] {
        didSet {
            guard let user = user else { return }
            var tempRecipes: [Recipe] = []
            let group = DispatchGroup()
            for recipeId in self.savedRecipsId {
                group.enter()
                let docRef = FirestoreEndpoint.recipes.collectionRef.document(recipeId)
                self.firestoreManager.getDocument(docRef) { (result: Result<Recipe?, Error>) in
                    switch result {
                    case .success(let recipe):
                        guard let recipe = recipe else { return }
                        if !user.blockList.contains(recipe.authorId) {
                            tempRecipes.append(recipe)
                        }
                    case .failure(let error):
                        AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
                    }
                    group.leave()
                }
            }
            group.notify(queue: DispatchQueue.main) { [weak self] in
                guard let self = self else { return }
                self.savedRecipes = tempRecipes.sorted { $0.time.seconds > $1.time.seconds }
                self.collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        title = "我的收藏"
        navigationItem.backButtonTitle = ""
        seeRecipeButton.tintColor = .darkBrown
        seeRecipeButton.backgroundColor = .lightOrange
        seeRecipeButton.layer.cornerRadius = 15
        seeRecipeButton.addTarget(self, action: #selector(seeRecipe), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertStackView.isHidden = true
        let userRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
        firestoreManager.getDocument(userRef) { [weak self] (result: Result<User?, Error>) in
            switch result {
            case .success(let user):
                guard let self = self, let user = user else { return }
                self.user = user
                self.savedRecipsId = user.savedRecipesId
                if user.savedRecipesId.isEmpty {
                    self.alertStackView.isHidden = false
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.registerCellWithNib(identifier: HotRecipeCell.identifier, bundle: nil)
    }

    @objc func seeRecipe() {
        self.tabBarController?.selectedIndex = 0
    }
}

extension SavedRecipeViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.85))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension SavedRecipeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        savedRecipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotRecipeCell.identifier, for: indexPath) as? HotRecipeCell
        else { fatalError("Could not create cell") }
        let recipe = savedRecipes[indexPath.item]
        cell.layoutCell(with: recipe)
        return cell
    }
}

extension SavedRecipeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
        guard
            let detailVC = storyboard.instantiateViewController(withIdentifier: String(describing: DetailRecipeViewController.self))
            as? DetailRecipeViewController
        else { fatalError("Could not instantiate detailVC") }
        let recipe = savedRecipes[indexPath.item]
        detailVC.recipeId = recipe.recipeId
        collectionView.deselectItem(at: indexPath, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
