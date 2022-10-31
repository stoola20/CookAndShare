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
    var searchType: SearchType?
    var searchString = String.empty
    let firestoreManager = FirestoreManager()
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        downloadRecipes()
        print(self.searchType)
        print(self.searchString)
    }
    
    func downloadRecipes() {
        firestoreManager.downloadRecipe { result in
            switch result {
            case .success(let recipes):
                self.recipes = recipes
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
