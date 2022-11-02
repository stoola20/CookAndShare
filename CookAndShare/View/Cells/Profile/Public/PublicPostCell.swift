//
//  PublicPostCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/2.
//

import UIKit

class PublicPostCell: UICollectionViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImageView.contentMode = .scaleAspectFill
    }
}
