//
//  UIDatePicker+Ext.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/10.
//

import UIKit

extension UIDatePicker {
    var textColor: UIColor? {
        get {
            return value(forKeyPath: "textColor") as? UIColor
        }
        set {
            setValue(newValue, forKeyPath: "textColor")
        }
    }
}
