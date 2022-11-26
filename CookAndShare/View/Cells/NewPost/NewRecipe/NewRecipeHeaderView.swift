//
//  NewRecipeHeaderView.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import UIKit

class NewRecipeHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: NewRecipeHeaderView.self)
    lazy var label = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureHeader()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureHeader() {
        addSubview(label)
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor.darkBrown
        label.translatesAutoresizingMaskIntoConstraints = false

        let inset: CGFloat = 16
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset)
        ])
    }
}
