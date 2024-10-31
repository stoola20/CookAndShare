//
//  ResultViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SPAlert

enum SearchType {
    case title
    case ingredient
    case camera
    case random
}

class ResultViewController: UIViewController {
    var recipes: [Recipe]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                guard let recipes = self.recipes else { return }
                self.stackView.isHidden = recipes.isEmpty ? false : true
            }
        }
    }
    var searchType: SearchType = .title
    var searchString = String.empty
    let firestoreManager = FirestoreManager.shared
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertMessageLabel: UILabel!
    @IBOutlet weak var addRecipeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        title = Constant.searchResult
        setUpUI()
        navigationItem.backButtonTitle = ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchRecipes()
    }

    func setUpUI() {
        alertTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        alertTitleLabel.textColor = UIColor.darkBrown
        alertTitleLabel.text = Constant.notFound

        alertMessageLabel.font = UIFont.systemFont(ofSize: 18)
        alertMessageLabel.textColor = UIColor.darkBrown
        alertMessageLabel.text = Constant.beTheFirstOne

        addRecipeButton.backgroundColor = UIColor.lightOrange
        addRecipeButton.setTitle(Constant.addNewRecipe, for: .normal)
        addRecipeButton.layer.cornerRadius = 20
        addRecipeButton.addTarget(self, action: #selector(presentNewRecipeVC), for: .touchUpInside)
    }

    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.registerCellWithNib(identifier: AllRecipeCell.identifier, bundle: nil)
    }

    func searchRecipes() {
        stackView.isHidden = true
        if Auth.auth().currentUser == nil {
            let query = FirestoreEndpoint.recipes.collectionRef
            getRecipes(query: query)
        } else {
            let docRef = FirestoreEndpoint.users.collectionRef.document(Constant.getUserId())
            firestoreManager.getDocument(docRef) { [weak self] (result: Result<User?, Error>) in
                switch result {
                case .success(let user):
                    guard let self = self, let user = user else { return }
                    let query = user.blockList.isEmpty
                    ? FirestoreEndpoint.recipes.collectionRef
                    : FirestoreEndpoint.recipes.collectionRef.whereField(Constant.authorId, notIn: user.blockList)
                    self.getRecipes(query: query)
                case .failure(let error):
                    AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
                }
            }
        }
    }

    private func getRecipes(query: Query) {
        firestoreManager.getDocuments(query) { [weak self] (result: Result<[Recipe], Error>) in
            switch result {
            case .success(let recipes):
                guard let self = self else { return }
                self.filterRecipes(recipes: recipes)
            case .failure(let error):
                AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
            }
        }
    }

    func filterRecipes(recipes: [Recipe]) {
        switch self.searchType {
        case .title:
            self.recipes = recipes.filter { recipe in
                return recipe.title.localizedCaseInsensitiveContains(self.searchString)
            }
        case .ingredient:
            self.recipes = recipes.filter { recipe in
                var isMach = false
                recipe.ingredientNames.forEach { ingredientName in
                    let ingredientIsMatch = ingredientName.localizedCaseInsensitiveContains(self.searchString)
                    if !ingredientIsMatch { return }
                    isMach = ingredientIsMatch
                }
                return isMach
            }
        case .camera:
            self.recipes = recipes.filter { recipe in
                var isMach = false
                let titleIsMatch = recipe.title.localizedCaseInsensitiveContains(self.searchString)
                recipe.ingredientNames.forEach { ingredientName in
                    let ingredientIsMatch = ingredientName.localizedCaseInsensitiveContains(self.searchString)
                    if !ingredientIsMatch {
                        isMach = titleIsMatch
                    } else {
                        isMach = ingredientIsMatch
                    }
                }
                return isMach
            }
        case .random:
            guard let randomRecipe = recipes.randomElement() else { return }
            self.recipes = [randomRecipe]
        }
    }

    @objc func presentNewRecipeVC() {
        let storyboard = UIStoryboard(name: Constant.newpost, bundle: nil)
        guard
            let newRecipeVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: NewRecipeViewController.self)
            )
            as? NewRecipeViewController
        else { fatalError("Could not create new recipe VC") }
        navigationController?.pushViewController(newRecipeVC, animated: true)
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
        cell.viewController = self
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

        detailVC.recipeId = recipes[indexPath.item].recipeId
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
