//
//  ShareCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import UIKit

protocol ShareCellDelegate: AnyObject {
    func goToProfile(_ userId: String)
}

class ShareCell: UITableViewCell {
    let firestoreManager = FirestoreManager.shared
    var userId = String.empty
    weak var delegate: ShareCellDelegate!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bestBeforeLabel: UILabel!
    @IBOutlet weak var meetTimeLabel: UILabel!
    @IBOutlet weak var meetPlaceLabel: UILabel!
    @IBOutlet weak var foodImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.contentMode = .scaleAspectFill
        foodImageView.contentMode = .scaleAspectFill
        print(#function)
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(setGestureRecognizer())
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(setGestureRecognizer())
    }

    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
        return tapRecognizer
    }
    
    @objc func goToProfile() {
        delegate.goToProfile(userId)
    }
    
    func layoutCell(with share: Share) {
        userId = share.authorId
        firestoreManager.fetchUserData(userId: share.authorId) { result in
            switch result {
            case .success(let user):
                self.userImageView.load(url: URL(string: user.imageURL)!)
                self.userNameLabel.text = user.name
            case .failure(let error):
                print(error)
            }
        }
        let timeInterval = Date() - Date(timeIntervalSince1970: Double(share.postTime.seconds))
        postTimeLabel.text = timeInterval.convertToString(from: timeInterval)
        titleLabel.text = "標題：\(share.title)"
        descriptionLabel.text = "描述：\(share.description)"
        bestBeforeLabel.text = "有效期限：\(Date.dateFormatter.string(from: Date(timeIntervalSince1970: Double(share.bestBefore.seconds))))"
        meetTimeLabel.text = "面交時間：\(share.meetTime)"
        meetPlaceLabel.text = "面交地點：\(share.meetPlace)"
        foodImageView.load(url: URL(string: share.imageURL)!)
    }
}
