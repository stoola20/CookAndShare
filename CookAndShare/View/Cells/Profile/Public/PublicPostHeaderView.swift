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
        recipeButton.isSelected = true
    }

    func setUpUI() {
        recipeButton.setImage(UIImage(named: "cooking"), for: .selected)
        recipeButton.setImage(UIImage(named: "cookingGray"), for: .normal)
        shareButton.setImage(UIImage(named: "share_gray_23"), for: .normal)
        shareButton.setImage(UIImage(named: "share_23"), for: .selected)
    }

    @IBAction func changeToRecipe(_ sender: UIButton) {
        toRecipe = true
        delegate.headerView(didChange: toRecipe)
        animateUnderline(sender)
        recipeButton.isSelected = true
        shareButton.isSelected = false
    }

    @IBAction func changeToShare(_ sender: UIButton) {
        toRecipe = false
        delegate.headerView(didChange: toRecipe)
        animateUnderline(sender)
        recipeButton.isSelected = false
        shareButton.isSelected = true
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
