//
//  ProcedureHeaderCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/20.
//

import UIKit

class ProcedureHeaderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = UIColor.darkBrown
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
    }
}
