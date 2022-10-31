//
//  RecipeTypeCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

class RecipeTypeCell: UICollectionViewCell {
    lazy var typeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    private func configureButton() {
        addSubview(typeButton)
        typeButton.backgroundColor = .lightGray
        typeButton.setTitleColor(.black, for: .normal)
        typeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let inset: CGFloat = 10
        
        NSLayoutConstraint.activate([
            typeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            typeButton.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            typeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }
}
