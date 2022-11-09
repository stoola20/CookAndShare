//
//  ResultViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit

enum SearchType {
    case title
    case ingredient
    case camera
    case random
}

class ResultViewController: UIViewController {
    var recipes: [Recipe]?
    var searchType: SearchType = .title
    var searchString = String.empty
    let firestoreManager = FirestoreManager()
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        title = Constant.searchResult
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchRecipes()
    }

    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.registerCellWithNib(identifier: AllRecipeCell.identifier, bundle: nil)
    }

    func searchRecipes() {
        firestoreManager.searchRecipe(type: searchType, query: searchString) { result in
            switch result {
            case .success(let recipes):
                if self.searchType == .random, let randomRecipe = recipes.randomElement() {
                    self.recipes = [randomRecipe]
                } else {
                    self.recipes = recipes
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let recipes = recipes else { return 0 }
        return recipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllRecipeCell.identifier, for: indexPath)
            as? AllRecipeCell,
            let recipes = recipes
        else { fatalError("Could not create hot recipe cell") }

        cell.layoutCell(with: recipes[indexPath.item])
        return cell
    }
}

extension ResultViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)

        guard
            let detailVC = storyboard.instantiateViewController(withIdentifier: String(describing: DetailRecipeViewController.self))
            as? DetailRecipeViewController,
            let recipes = recipes
        else { fatalError("Could not instantiate detailVC") }

        detailVC.recipe = recipes[indexPath.item]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ResultViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(0.35))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        return UICollectionViewCompositionalLayout(section: section)
    }
}
