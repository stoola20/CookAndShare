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
    @IBOutlet weak var underlineLeading: NSLayoutConstraint!
    @IBOutlet weak var underline: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        recipeButton.tintColor = UIColor.myOrange
        shareButton.tintColor = UIColor.gray
    }

    @IBAction func changeToRecipe(_ sender: UIButton) {
        toRecipe = true
        delegate.headerView(didChange: toRecipe)
        animateUnderline(sender)
        recipeButton.tintColor = UIColor.myOrange
        shareButton.tintColor = UIColor.lightGray
    }

    @IBAction func changeToShare(_ sender: UIButton) {
        toRecipe = false
        delegate.headerView(didChange: toRecipe)
        animateUnderline(sender)
        recipeButton.tintColor = UIColor.lightGray
        shareButton.tintColor = UIColor.myOrange
    }

    func animateUnderline(_ sender: UIButton) {
        underlineLeading.isActive = false
        underlineLeading = underline.leadingAnchor.constraint(equalTo: sender.leadingAnchor)
        underlineLeading.isActive = true

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
}
