//
//  InfoWindowView.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit
import CoreLocation

class InfoWindowView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var navigateButton: UIButton!

    func layoutView(name: String, address: String) {
        navigateButton.setTitleColor(.myGreen, for: .normal)
        navigateButton.backgroundColor = .lightOrange
        navigateButton.layer.cornerRadius = 13
        nameLabel.text = name
        addressLabel.text = address
        nameLabel.textColor = UIColor.darkBrown
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addressLabel.textColor = UIColor.darkBrown
        addressLabel.font = UIFont.systemFont(ofSize: 16)
        self.frame = CGRect(x: 10, y: 10, width: 300, height: 150)
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.systemYellow.cgColor
        self.layer.borderWidth = 2
        self.alpha = 0.95
    }
}
