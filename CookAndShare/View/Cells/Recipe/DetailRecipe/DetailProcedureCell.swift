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
        // Initialization code
    }
    
    func layoutCell(with procedure: Procedure, at indexPath: IndexPath) {
        stepLabel.text = String(indexPath.row + 1)
        procedureImageView.load(url: URL(string: procedure.imageURL)!)
        descriptionTextVIew.text = procedure.description
    }
    
}