//
//  DetailProcedureCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit

class DetailProcedureCell: UITableViewCell {

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var procedureImageView: UIImageView!
    @IBOutlet weak var descriptionTextVIew: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        stepLabel.textColor = UIColor.darkBrown
        descriptionTextVIew.textColor = UIColor.darkBrown
        descriptionTextVIew.font = UIFont.systemFont(ofSize: 17)
        procedureImageView.contentMode = .scaleAspectFill
        procedureImageView.layer.cornerRadius = 15
    }
    
    func layoutCell(with procedure: Procedure, at indexPath: IndexPath) {
        stepLabel.text = String(indexPath.row + 1)
        procedureImageView.loadImage(procedure.imageURL, placeHolder: UIImage(named: Constant.friedRice))
        descriptionTextVIew.text = procedure.description
    }
}
