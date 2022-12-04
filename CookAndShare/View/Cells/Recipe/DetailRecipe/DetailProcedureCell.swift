//
//  DetailProcedureCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit
import Hero

class DetailProcedureCell: UITableViewCell {
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var procedureImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    weak var viewController: DetailRecipeViewController?
    var foodImageURL = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        procedureImageView.isUserInteractionEnabled = true
        procedureImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentLargePhoto)))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        procedureImageView.image = UIImage(named: Constant.friedRice)
    }

    func setUpUI() {
        stepLabel.textColor = UIColor.darkBrown
        descriptionLabel.textColor = UIColor.darkBrown
        descriptionLabel.font = UIFont.systemFont(ofSize: 17)
        procedureImageView.contentMode = .scaleAspectFill
        procedureImageView.layer.cornerRadius = 15
    }

    func layoutCell(with procedure: Procedure, at indexPath: IndexPath) {
        stepLabel.text = String(indexPath.row + 1)
        procedureImageView.loadImage(procedure.imageURL, placeHolder: UIImage(named: Constant.friedRice))
        descriptionLabel.text = procedure.description
        foodImageURL = procedure.imageURL
    }

    @objc func presentLargePhoto() {
        let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
        guard
            let previewVC = storyboard.instantiateViewController(withIdentifier: String(describing: PreviewViewController.self))
                as? PreviewViewController
        else { fatalError("Could not create previewVC") }
        previewVC.imageURL = foodImageURL
        previewVC.heroId = procedureImageView.heroID ?? ""
        previewVC.modalPresentationStyle = .overFullScreen
        viewController?.present(previewVC, animated: true)
    }
}
