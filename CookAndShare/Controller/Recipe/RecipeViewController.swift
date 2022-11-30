//
//  ViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import UIKit
import FirebaseAuth
import ESPullToRefresh
import CoreData
import SPAlert

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
}

class RecipeViewController: UIViewController {
    let firestoreManager = FirestoreManager.shared
    var selectedTag = 0
    var indexPath = IndexPath(item: 0, section: 0)
    var hotRecipes: [Recipe]?
    var allRecipes: [Recipe]?
    var filterdRecipes: [Recipe]? {
        didSet {
            if let filterdRecipes = filterdRecipes,
                filterdRecipes.isEmpty {
                SPAlert.present(message: "找不到符合的食譜結果", haptic: .warning)
            }
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(integer: 2))
            }
        }
    }

    var header: ESRefreshHeaderAnimator {
        let header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        header.pullToRefreshDescription = "下拉更新"
        header.releaseToRefreshDescription = ""
        header.loadingDescription = "載入中..."
        return header
    }

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "食譜"
        setUpCollectionView()
        setUpNavBar()
        collectionView.es.addPullToRefresh(animator: header) { [weak self] in
            guard let self = self else { return }
            self.downloadRecipes()
        }
        collectionView.es.startPullToRefresh()
    }

    func setUpNavBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "magnifyingglass.circle"),
                style: .plain,
                target: self,
                action: #selector(searchRecipes)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "plus.circle"),
                style: .plain,
                target: self,
                action: #selector(addRecipe)
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
        navigationItem.backButtonTitle = ""
    }

    @objc func searchRecipes() {
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
        guard let searchVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: SearchViewController.self))
                as? SearchViewController
        else { fatalError("Could not create search VC") }
        navigationController?.pushViewController(searchVC, animated: true)
    }

    @objc func addRecipe() {
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
            guard let newpostVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: NewRecipeViewController.self))
                    as? NewRecipeViewController
            else { fatalError("Could not create newpostVC") }
            navigationController?.pushViewController(newpostVC, animated: true)
        }
    }

    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.registerCellWithNib(identifier: HotRecipeCell.identifier, bundle: nil)
        collectionView.registerCellWithNib(identifier: AllRecipeCell.identifier, bundle: nil)
        collectionView.register(RecipeTypeCell.self, forCellWithReuseIdentifier: RecipeTypeCell.identifier)
        collectionView.register(
            RecipeHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RecipeHeaderView.identifier
        )
    }

    func downloadRecipes() {
        firestoreManager.searchAllRecipes { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let recipes):
                let tempRecipes = recipes.sorted { $0.likes.count > $1.likes.count }
                var tempHot: [Recipe] = []
                for index in 0..<tempRecipes.count where index <= 9 {
                    tempHot.append(tempRecipes[index])
                }
                self.hotRecipes = tempHot

                self.allRecipes = recipes.sorted { $0.time.seconds > $1.time.seconds }
                self.filterRecipe(byTag: self.selectedTag)

                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                    self.collectionView.es.stopPullToRefresh()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func recipeFilter(by meat: String) {
        filterdRecipes = allRecipes?.filter { recipe in
            var isMach = false
            recipe.ingredientNames.forEach { name in
                let nameIsMatch = name.localizedCaseInsensitiveContains(meat)
                if nameIsMatch != true { return }
                isMach = nameIsMatch
            }
            return isMach
        }
    }

    func recipeFilterByVegetable() {
        filterdRecipes = allRecipes?.filter { recipe in
            var isMach = true
            recipe.ingredientNames.forEach { name in
                let containsChicken = name.localizedCaseInsensitiveContains("雞")
                let containsBeef = name.localizedCaseInsensitiveContains("牛")
                let containsPork = name.localizedCaseInsensitiveContains("豬")
                let containsShrimp = name.localizedCaseInsensitiveContains("蝦")
                let containsFish = name.localizedCaseInsensitiveContains("魚")
                let containsMeat = name.localizedCaseInsensitiveContains("肉")

                let notVegan = containsChicken || containsPork || containsBeef || containsFish || containsShrimp || containsMeat
                if !notVegan { return }
                isMach = !notVegan
            }
            return isMach
        }
    }

    func filterRecipe(byTag tag: Int) {
        switch tag {
        case 0:
            filterdRecipes = allRecipes
        case 1:
            recipeFilter(by: "牛")
        case 2:
            recipeFilter(by: "豬")
        case 3:
            recipeFilter(by: "雞")
        default:
            recipeFilterByVegetable()
        }
    }
}

extension RecipeViewController: RecipeTypeCellDelegate {
    func didSelectedButton(_ cell: RecipeTypeCell, tag: Int) {
        for index in 0..<RecipeType.allCases.count {
            guard
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 1))
                    as? RecipeTypeCell
            else { fatalError("Could not create cell") }
            cell.typeButton.backgroundColor = .lightOrange
            cell.typeButton.setTitleColor(.darkBrown, for: .normal)
        }
        self.selectedTag = tag
        filterRecipe(byTag: tag)

        cell.typeButton.backgroundColor = .darkBrown
        cell.typeButton.setTitleColor(.lightOrange, for: .normal)
    }
}

// MARK: - UICollectionViewDataSource
extension RecipeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        RecipeSection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard
            let hotRecipes = hotRecipes,
            let filterdRecipes = filterdRecipes
        else { return 0 }

        switch section {
        case 0:
            return hotRecipes.count
        case 1:
            return RecipeType.allCases.count
        default:
            return filterdRecipes.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let hotRecipes = hotRecipes,
            let filterdRecipes = filterdRecipes
        else { fatalError("empty recipes") }

        switch indexPath.section {
        case 0:
            guard
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotRecipeCell.identifier, for: indexPath)
                    as? HotRecipeCell
            else { fatalError("Could not create hot recipe cell") }
            cell.viewController = self
            cell.layoutCell(with: hotRecipes[indexPath.item])
            return cell

        case 1:
            guard
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeTypeCell.identifier, for: indexPath)
                    as? RecipeTypeCell
            else { fatalError("Could not create hot recipe cell") }
            cell.delegate = self
            cell.typeButton.tag = indexPath.item
            cell.typeButton.setTitle(RecipeType.allCases[indexPath.item].rawValue, for: .normal)
            cell.updateButtonColor(seletedTag: selectedTag)

            return cell

        default:
            guard
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllRecipeCell.identifier, for: indexPath)
                    as? AllRecipeCell
            else { fatalError("Could not create hot recipe cell") }
            cell.viewController = self
            cell.layoutCell(with: filterdRecipes[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
        case 0, 1:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: RecipeHeaderView.identifier,
                for: indexPath) as? RecipeHeaderView
            else { fatalError("Could not create new post header view") }

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
        collectionView.deselectItem(at: indexPath, animated: false)
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: DetailRecipeViewController.self))
                as? DetailRecipeViewController
        else { fatalError("Could not instantiate detailVC") }

        switch indexPath.section {
        case 0:
            guard let hotRecipes = hotRecipes else { return }
            detailVC.recipeId = hotRecipes[indexPath.item].recipeId
            navigationController?.pushViewController(detailVC, animated: true)
        case 1:
            return
        default:
            guard let filterdRecipes = filterdRecipes else { return }
            detailVC.recipeId = filterdRecipes[indexPath.item].recipeId
            navigationController?.pushViewController(detailVC, animated: true)
        }
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

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalWidth(0.7))
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

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.22), heightDimension: .absolute(65))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
                section.boundarySupplementaryItems = [sectionHeader]

                return section

            default:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(230))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)

                return section
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
