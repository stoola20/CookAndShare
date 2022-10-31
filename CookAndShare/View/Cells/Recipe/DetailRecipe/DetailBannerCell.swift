//
//  DetailBannerCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

class DetailBannerCell: UITableViewCell {
    @IBOutlet weak var mainImageVIew: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var storyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        mainImageVIew.contentMode = .scaleAspectFill
    }
    
    func layoutCell(with recipe: Recipe) {
        mainImageVIew.load(url: URL(string: recipe.mainImageURL)!)
        titleLabel.text = recipe.title
        durationLabel.text = "⌛️ \(recipe.cookDuration) 分鐘"
        authorLabel.text = recipe.authorId
        storyLabel.text = recipe.description
    }
}
