//
//  BLockListCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/22.
//

import UIKit

class BLockListCell: UITableViewCell {
    @IBOutlet weak var unBlockButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var completion: ((BLockListCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unBlockButton.layer.cornerRadius = 5
        unBlockButton.layer.borderColor = UIColor.darkBrown?.cgColor
        unBlockButton.layer.borderWidth = 1
        unBlockButton.tintColor = .darkBrown
        nameLabel.textColor = .darkBrown
        profileImageView.layer.cornerRadius = 15
        profileImageView.contentMode = .scaleAspectFill
    }

    func layoutCell(with user: User) {
        nameLabel.text = user.name
        profileImageView.loadImage(user.imageURL, placeHolder: UIImage(named: Constant.chefMan))
    }

    @IBAction func unBlock(_ sender: UIButton) {
        completion?(self)
    }
}
