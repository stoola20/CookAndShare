//
//  DateHeaderView.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/12/2.
//

import UIKit

class DateHeaderLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 20, height: height)
    }
}

class DateHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: DateHeaderView.self)
    lazy var label = DateHeaderLabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureHeader()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureHeader() {
        self.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.darkBrown
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
