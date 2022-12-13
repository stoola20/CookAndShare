//
//  OtherImageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/5.
//

import UIKit
import Hero

class OtherImageCell: UITableViewCell, MessageCell {
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var imageTimeLabel: UILabel!
    weak var viewController: ChatRoomViewController?
    var imageURL = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        largeImageView.isUserInteractionEnabled = true
        largeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentLargePhoto)))
    }

    func setUpUI() {
        largeImageView.layer.cornerRadius = 20
        friendImageView.layer.cornerRadius = 20
        largeImageView.contentMode = .scaleAspectFill
        friendImageView.contentMode = .scaleAspectFill
        imageTimeLabel.textColor = UIColor.systemBrown
        imageTimeLabel.font = UIFont.systemFont(ofSize: 13)
    }

    func layoutCell(with message: Message, friendImageURL: String, viewController: ChatRoomViewController, heroId: String) {
        friendImageView.loadImage(friendImageURL, placeHolder: UIImage(named: Constant.chefMan))
        largeImageView.loadImage(message.content, placeHolder: UIImage(named: Constant.friedRice))
        largeImageView.heroID = heroId
        imageTimeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
        imageURL = message.content
        self.viewController = viewController
    }

    @objc func presentLargePhoto() {
        let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
        guard let previewVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: PreviewViewController.self)
        ) as? PreviewViewController
        else { fatalError("Could not create previewVC") }
        previewVC.imageURL = imageURL
        previewVC.heroId = largeImageView.heroID ?? ""
        previewVC.modalPresentationStyle = .overFullScreen
        viewController?.present(previewVC, animated: true)
    }
}
