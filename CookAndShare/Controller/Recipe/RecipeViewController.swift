//
//  ViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import UIKit

enum RecipeSection: String, CaseIterable {
    case hot = "熱門食譜🔥"
    case type = "類型"
    case all
}

enum RecipeType: String, CaseIterable {
    case all = "全部"
    case beef = "牛肉"
    case pork = "豬肉"
    case chicken = "雞肉"
    case vegetarian = "蔬食"
    case other = "其他"
}

class RecipeViewController: UIViewController {
    
    let firestoreManager = FirestoreManager.shared
    var hotRecipes: [Recipe]?
    var allRecipes: [Recipe]?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchRecipes))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadRecipes()
    }
    
    @objc func searchRecipes() {
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
        guard let searchVC = storyboard.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController else { fatalError("Could not create search VC") }
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.registerCellWithNib(identifier: HotRecipeCell.identifier, bundle: nil)
        collectionView.registerCellWithNib(identifier: AllRecipeCell.identifier, bundle: nil)
        collectionView.register(RecipeTypeCell.self, forCellWithReuseIdentifier: RecipeTypeCell.identifier)
        collectionView.register(RecipeHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecipeHeaderView.identifier)
    }
    
    func downloadRecipes() {
        firestoreManager.downloadRecipe { result in
            switch result {
            case .success(let recipes):
                self.hotRecipes = recipes
                self.allRecipes = recipes
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension RecipeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        RecipeSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let hotRecipes = hotRecipes,
              let allRecipes = allRecipes
        else { return 0 }

        switch section {
        case 0:
            return hotRecipes.count
        case 1:
            return RecipeType.allCases.count
        default:
            return allRecipes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let hotRecipes = hotRecipes,
              let allRecipes = allRecipes
        else { fatalError() }

        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotRecipeCell.identifier, for: indexPath) as? HotRecipeCell else {
                fatalError("Could not create hot recipe cell")
            }
            cell.imageView.load(url: URL(string: hotRecipes[indexPath.item].mainImageURL)!)
            cell.likesLabel.text = String(hotRecipes[indexPath.item].likes)
            cell.titleLabel.text = hotRecipes[indexPath.item].title
            cell.durationLabel.text = "⌛️ \(hotRecipes[indexPath.item].cookDuration) 分鐘"
            return cell

        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeTypeCell.identifier, for: indexPath) as? RecipeTypeCell else {
                fatalError("Could not create hot recipe cell")
            }
            cell.typeButton.setTitle(RecipeType.allCases[indexPath.item].rawValue, for: .normal)
            return cell

        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllRecipeCell.identifier, for: indexPath) as? AllRecipeCell else {
                fatalError("Could not create hot recipe cell")
            }
            cell.imageView.load(url: URL(string: allRecipes[indexPath.item].mainImageURL)!)
            cell.titleLabel.text = allRecipes[indexPath.item].title
            cell.durationLabel.text = "⌛️ \(allRecipes[indexPath.item].cookDuration) 分鐘"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
            case 0, 1:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecipeHeaderView.identifier, for: indexPath) as? RecipeHeaderView else { fatalError("Could not create new post header view") }

                headerView.textLabel.text = RecipeSection.allCases[indexPath.section].rawValue
                return headerView

            default:
                return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension RecipeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: String(describing: DetailRecipeViewController.self)) as? DetailRecipeViewController else { fatalError("Could not instantiate detailVC") }

        switch indexPath.section {
        case 0:
            guard let hotRecipes = hotRecipes else { return }
            detailVC.recipe = hotRecipes[indexPath.item]

        default:
            guard let allRecipes = allRecipes else { return }
            detailVC.recipe = allRecipes[indexPath.item]
        }

        collectionView.deselectItem(at: indexPath, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension RecipeViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .fractionalHeight(0.4))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section

            case 1:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .absolute(44))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section

            default:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalHeight(0.4))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                
                return section
            }
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
