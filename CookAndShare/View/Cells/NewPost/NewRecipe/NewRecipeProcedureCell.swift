//
//  NewRecipeProcedureCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import UIKit

protocol NewRecipeProcedureDelegate: AnyObject {
    func didDelete(_ cell: NewRecipeProcedureCell)
    func didAddProcedure(_ cell: NewRecipeProcedureCell, description: String)
    func willPickImage(_ cell: NewRecipeProcedureCell)
    func addProcedure()
}

class NewRecipeProcedureCell: UITableViewCell {
    weak var delegate: NewRecipeProcedureDelegate!

    @IBOutlet weak var stepImageView: UIImageView!
    @IBOutlet weak var procedureTextField: UITextField! {
        didSet {
            procedureTextField.delegate = self
        }
    }
    @IBOutlet weak var procedureImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        deleteButton.isHidden = true
        procedureImageView.isUserInteractionEnabled = true
        procedureImageView.addGestureRecognizer(setGestureRecognizer())
    }

    func setUpUI() {
        stepImageView.tintColor = UIColor.darkBrown
        deleteButton.tintColor = UIColor.darkBrown
        procedureImageView.layer.cornerRadius = 5
        procedureImageView.contentMode = .scaleAspectFill
    }

    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        return tapRecognizer
    }

    func layoutCell(with indexPath: IndexPath) {
        let step = indexPath.row + 1
        stepImageView.image = UIImage(systemName: "\(step).circle.fill")

        switch step {
        case 1:
            procedureTextField.placeholder = Constant.procedureStep1
        case 2:
            procedureTextField.placeholder = Constant.procedureStep2
        case 3:
            procedureTextField.placeholder = Constant.procedureStep3
        default:
            procedureTextField.placeholder = "請輸入步驟"
        }
    }

    @IBAction func deleteProcedure(_ sender: UIButton) {
        delegate.didDelete(self)
    }

    @objc func pickImage() {
        delegate.willPickImage(self)
    }

    func passData() {
        guard let description = procedureTextField.text else { return }
        if !description.isEmpty {
            delegate.didAddProcedure(self, description: description)
            delegate.addProcedure()
            deleteButton.isHidden = false
        }
    }
}

// MARK: - TextField Delegate
extension NewRecipeProcedureCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        passData()
    }
}
