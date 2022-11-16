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
        case .logout:
            smallImageView.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
            listLabel.textColor = UIColor.systemRed
        }
    }
}
