//
//  HotRecipeCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

class HotRecipeCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
    }

    @IBAction func storeRecipe(_ sender: UIButton) {

    }
}
