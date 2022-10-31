//
//  NewRecipeFooterView.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import UIKit

class NewRecipeFooterView: UITableViewHeaderFooterView {

    static let reuseIdentifier: String = String(describing: NewRecipeFooterView.self)
    lazy var button = UIButton()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureFooter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureFooter() {
        addSubview(button)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        let inset: CGFloat = 16
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            button.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

}
