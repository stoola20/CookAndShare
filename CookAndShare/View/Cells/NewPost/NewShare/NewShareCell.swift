//
//  NewShareCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit
import FirebaseFirestore

struct NewShareModel {
    var title = String.empty
    var description = String.empty
    var meetTime = String.empty
    var meetPlace = String.empty
    var bestBeforeDate = Timestamp()
    var dueDate = Timestamp()
}

protocol NewShareCellDelegate: AnyObject {
    func willPickImage()
}

class NewShareCell: UITableViewCell {
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var meetTimeTextField: UITextField!
    @IBOutlet weak var meetPlaceTextField: UITextField!
    @IBOutlet weak var bestBeforePicker: UIDatePicker!

    var completion: ((NewShareModel) -> Void)?
    var data = NewShareModel()
    weak var delegate: NewShareCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @objc func pickImage() {
        delegate.willPickImage()
    }

    func setUpView() {
        foodImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        foodImage.addGestureRecognizer(gestureRecognizer)
        foodImage.contentMode = .scaleAspectFill
        foodImage.layer.cornerRadius = 10
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        meetTimeTextField.delegate = self
        meetPlaceTextField.delegate = self

        titleTextField.placeholder = Constant.shareTitle
        descriptionTextField.placeholder = Constant.shareDesription
        meetTimeTextField.placeholder = Constant.meetTime
        meetPlaceTextField.placeholder = Constant.meetPlace

        let currentDate = Date()
        bestBeforePicker.minimumDate = currentDate
        bestBeforePicker.addTarget(self, action: #selector(passData), for: .valueChanged)
        bestBeforePicker.textColor = UIColor.darkBrown
    }

    func layoutCell(with share: Share) {
        foodImage.loadImage(share.imageURL, placeHolder: UIImage(named: "takePhoto"))
        titleTextField.text = share.title
        descriptionTextField.text = share.description
        meetTimeTextField.text = share.meetTime
        meetPlaceTextField.text = share.meetPlace
        bestBeforePicker.setDate(Date(timeIntervalSince1970: Double(share.bestBefore.seconds)), animated: true)
    }

    @objc func passData() {
        guard
            let title = titleTextField.text,
            let description = descriptionTextField.text,
            let meetTime = meetTimeTextField.text,
            let meetPlace = meetPlaceTextField.text
        else { return }
        data.title = title
        data.description = description
        data.meetTime = meetTime
        data.meetPlace = meetPlace
        data.bestBeforeDate = Timestamp(date: bestBeforePicker.date)
        data.dueDate = Timestamp(date: Date())
        completion?(data)
    }
}

extension NewShareCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        passData()
    }
}
