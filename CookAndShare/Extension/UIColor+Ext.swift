//
//  UIColor+Ext.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/9.
//

import UIKit

enum MyColor: String {
    // swiftlint:disable identifier_name
    case DarkBrown
    case MyOrange
    case LightOrange
    case BackGround
    case MyGreen
}

extension UIColor {
    static let darkBrown = myColor(.DarkBrown)
    static let myOrange = myColor(.MyOrange)
    static let lightOrange = myColor(.LightOrange)
    static let backGround = myColor(.BackGround)
    static let myGreen = myColor(.MyGreen)

    private static func myColor(_ color: MyColor) -> UIColor? {
        return UIColor(named: color.rawValue)
    }
}
