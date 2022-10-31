//
//  UICollectionView+Ext.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation
import UIKit

extension UICollectionView {
    func registerCellWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
}

extension UICollectionReusableView {
    static var identifier: String {
        return String(describing: self)
    }
}
