//
//  RecipeTypeCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit
protocol RecipeTypeCellDelegate: AnyObject {
    func didSelectedButton(tag: Int)
}

class RecipeTypeCell: UICollectionViewCell {
    lazy var typeButton = UIButton()
    weak var delegate: RecipeTypeCellDelegate!
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    private func configureButton() {
        addSubview(typeButton)
        typeButton.addTarget(self, action: #selector(pressButton(_:)), for: .touchUpInside)
        typeButton.backgroundColor = UIColor.lightOrange
        typeButton.setTitleColor(UIColor.darkBrown, for: .normal)
        typeButton.layer.cornerRadius = 10
        typeButton.translatesAutoresizingMaskIntoConstraints = false

        let inset: CGFloat = 5

        NSLayoutConstraint.activate([
            typeButton.widthAnchor.constraint(equalToConstant: 70),
            typeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            typeButton.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            typeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }

    @objc func pressButton(_ sender: UIButton) {
        delegate.didSelectedButton(tag: sender.tag)
    }
}
