//
//  PublicPostHeaderView.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/2.
//

import UIKit
protocol PublicPostHeaderViewDelegate: AnyObject {
    func headerView(didChange: Bool)
}

class PublicPostHeaderView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: PublicPostHeaderView.self)
    var toRecipe = true
    weak var delegate: PublicPostHeaderViewDelegate!
    @IBOutlet weak var recipeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func changeToRecipe(_ sender: UIButton) {
        toRecipe = true
        delegate.headerView(didChange: toRecipe)
    }

    @IBAction func changeToShare(_ sender: UIButton) {
        toRecipe = false
        delegate.headerView(didChange: toRecipe)
    }
}
