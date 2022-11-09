//
//  DetailRecipeHeaderView.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

protocol DetailRecipeHeaderViewDelegate: AnyObject {
    func willAddIngredient()
}

class DetailRecipeHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: DetailRecipeHeaderView.self)
    lazy var headerLabel = UILabel()
    lazy var quantityLabel = UILabel()
    lazy var addToListButton = UIButton()
    lazy var separator = UIView()
    weak var delegate: DetailRecipeHeaderViewDelegate!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureHeader()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureHeader() {
        addSubview(headerLabel)
        addSubview(quantityLabel)
        addSubview(addToListButton)
        addSubview(separator)
        headerLabel.font = UIFont.boldSystemFont(ofSize: 22)
        quantityLabel.font = UIFont.systemFont(ofSize: 18)
        headerLabel.textColor = UIColor.darkBrown
        quantityLabel.textColor = UIColor.darkBrown

        separator.backgroundColor = UIColor.lightOrange

        addToListButton.setTitle(Constant.addToShoppingList, for: .normal)
        addToListButton.setTitleColor(UIColor.backGround, for: .normal)
        addToListButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        addToListButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addToListButton.tintColor = UIColor.backGround
        addToListButton.addTarget(self, action: #selector(addToList), for: .touchUpInside)
        addToListButton.backgroundColor = UIColor.darkBrown
        addToListButton.layer.cornerRadius = 15

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        addToListButton.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false

        let inset: CGFloat = 16

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            headerLabel.bottomAnchor.constraint(equalTo: quantityLabel.topAnchor, constant: -inset / 2),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),

            quantityLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            quantityLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),

            addToListButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            addToListButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            addToListButton.widthAnchor.constraint(equalToConstant: 150),
            addToListButton.heightAnchor.constraint(equalToConstant: 30),

            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset)
        ])
    }

    func layoutHeader(with recipe: Recipe, in section: Int) {
        if section == 1 {
            headerLabel.text = Constant.ingredient
            quantityLabel.text = String(recipe.quantity) + " " + Constant.quantityByPerson
        } else if section == 2 {
            headerLabel.text = Constant.procedure
            quantityLabel.isHidden = true
            addToListButton.isHidden = true
        }
    }

    @objc func addToList() {
        delegate.willAddIngredient()
    }
}
