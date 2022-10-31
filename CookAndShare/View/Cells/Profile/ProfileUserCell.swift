//
//  ProfileUserCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/31.
//

import UIKit

class ProfileUserCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func layoutCell(with user: User) {
        userName.text = user.name
        guard let url = URL(string:user.imageURL) else { return }
        profileImageView.load(url: url)
    }
}
