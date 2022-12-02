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
