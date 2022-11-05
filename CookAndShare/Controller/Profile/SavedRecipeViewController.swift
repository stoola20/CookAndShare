//
//  SavedRecipeViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit

class SavedRecipeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let firestoreManager = FirestoreManager.shared
    var savedRecipes: [Recipe] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var savedRecipsId: [String] = [] {
        didSet {
            for id in savedRecipsId {
                firestoreManager.searchRecipesById(id) { result in
                    switch result {
                    case .success(let recipe):
                        self.savedRecipes.append(recipe)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }

    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.registerCellWithNib(identifier: HotRecipeCell.identifier, bundle: nil)
    }
}

extension SavedRecipeViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.4))
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
        detailVC.recipe = recipe
        collectionView.deselectItem(at: indexPath, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
