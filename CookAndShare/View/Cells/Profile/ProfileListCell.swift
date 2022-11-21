//
//  ProfileListCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit

class ProfileListCell: UITableViewCell {
    @IBOutlet weak var smallImageView: UIImageView!
    @IBOutlet weak var listLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        smallImageView.tintColor = UIColor.myGreen
    }

    func layoutCell(in category: ProfileCategory) {
        listLabel.text = category.rawValue

        switch category {
        case .save:
            smallImageView.image = UIImage(systemName: "bookmark.circle")
            listLabel.textColor = UIColor.darkBrown
        case .shoppingList:
            smallImageView.image = UIImage(systemName: "list.bullet")
            listLabel.textColor = UIColor.darkBrown
        case .myPost:
            smallImageView.image = UIImage(systemName: "text.below.photo")
            listLabel.textColor = UIColor.darkBrown
        case .block:
            smallImageView.image = UIImage(systemName: "hand.raised")
            listLabel.textColor = UIColor.darkBrown
        case .deleteAccount:
            smallImageView.image = UIImage(systemName: "trash")
            listLabel.textColor = UIColor.systemRed
        case .logout:
            smallImageView.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
            listLabel.textColor = UIColor.systemRed
        }
    }
}
