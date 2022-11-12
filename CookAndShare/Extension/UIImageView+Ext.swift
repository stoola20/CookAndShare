//
//  UIImageView+Ext.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit
import Kingfisher

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }

    func applyshadowWithCorner(containerView: UIView, cornerRadious: CGFloat) {
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowOpacity = 0.7
        containerView.layer.shadowOffset = CGSize(width: 0, height: 5)
        containerView.layer.shadowRadius = 2
        containerView.layer.cornerRadius = cornerRadious
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadious).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }

    func loadImage(_ urlString: String?, placeHolder: UIImage? = nil) {
        guard urlString != nil else { return }
        let url = URL(string: urlString!)
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: placeHolder,
            options: [
                .transition(.fade(1)),
                .cacheOriginalImage
            ]
        )
    }
}
