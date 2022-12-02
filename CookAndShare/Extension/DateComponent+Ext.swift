//
//  DateComponent+Ext.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/12/2.
//

import Foundation

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        guard
            let lhsY = lhs.year,
            let rhsY = rhs.year,
            let lhsM = lhs.month,
            let rhsM = rhs.month,
            let lhsD = lhs.day,
            let rhsD = rhs.day
        else { return false }
        if lhsY == rhsY {
            if lhsM == rhsM {
                return lhsD < rhsD
            } else {
                return lhsM < rhsM
            }
        } else {
            return lhsY < rhsY
        }
    }
}
