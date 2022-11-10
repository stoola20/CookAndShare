//
//  UserInputTextField.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/10.
//

import UIKit

class UserInputTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.background
        self.textColor = UIColor.darkBrown
        self.font = UIFont.systemFont(ofSize: 17)
        addUnderLine()
    }

    private func addUnderLine() {
        let underline = UIView()
        
        underline.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(underline)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: underline.leadingAnchor),
            trailingAnchor.constraint(equalTo: underline.trailingAnchor),
            bottomAnchor.constraint(equalTo: underline.bottomAnchor),
            underline.heightAnchor.constraint(equalToConstant: 1.0)
        ])

        underline.backgroundColor = UIColor.lightOrange
    }
}
