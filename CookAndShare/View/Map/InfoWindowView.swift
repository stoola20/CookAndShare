//
//  InfoWindowView.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit

class InfoWindowView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    func layoutView(name: String, address: String) {
        nameLabel.text = name
        addressLabel.text = address
        self.frame = CGRect(x: 10, y: 10, width: 300, height: 120)
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.systemYellow.cgColor
        self.layer.borderWidth = 2
        self.alpha = 0.9
    }
}
