//
//  NewPostViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import UIKit

class NewPostViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCollectionView()
    }

    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.registerCellWithNib(identifier: DraftCell.identifier, bundle: nil)
        collectionView.registerCellWithNib(identifier: NewPostCell.identifier, bundle: nil)
        collectionView.register(NewPostSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NewPostSupplementaryView.identifier)
        collectionView.register(
            DraftSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DraftSupplementaryView.identifier
        )
    }
}

extension NewPostViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 1, 3:
            return 1
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewPostCell.identifier, for: indexPath)
            as? NewPostCell
        else { fatalError("Could not create new post cell.") }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
        case 0, 2:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: NewPostSupplementaryView.identifier,
                for: indexPath) as? NewPostSupplementaryView
            else { fatalError("Could not create new post header view") }
            
            headerView.textLabel.text = indexPath.section == 0 ? Constant.newRecipe : Constant.newShare
            return headerView

        default:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: DraftSupplementaryView.identifier,
                for: indexPath) as? DraftSupplementaryView
            else { fatalError("Could not create draft header view") }
            
            headerView.textLabel.text = Constant.draft
            return headerView
        }
    }
}

extension NewPostViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "NewPost", bundle: nil)
        if indexPath == IndexPath(item: 0, section: 1) {
            guard
                let newRecipeVC = storyboard.instantiateViewController(withIdentifier: String(describing: NewRecipeViewController.self))
                    as? NewRecipeViewController
            else { fatalError("Could not instantiate newRecipeVC") }
            navigationController?.pushViewController(newRecipeVC, animated: true)
        } else if indexPath == IndexPath(item: 0, section: 3) {
            guard
                let newShareVC = storyboard.instantiateViewController(withIdentifier: String(describing: NewShareViewController.self))
                    as? NewShareViewController
            else { fatalError("Could not instantiate NewShareViewController") }
            navigationController?.pushViewController(newShareVC, animated: true)
        }
    }
}

extension NewPostViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/3))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        }

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
