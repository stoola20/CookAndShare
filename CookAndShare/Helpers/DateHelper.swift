//
//  DateHelper.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import Foundation

extension Date {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }

    static func getMessageTimeString(from messageTime: Date) -> String {
        let calendar = Calendar.current
        let timeInterval = Date() - messageTime
        let dayComponent = calendar.component(.day, from: messageTime)

        // 同一天的話顯示上午、下午
        if dayComponent == calendar.component(.day, from: Date()) {
            var hour = calendar.component(.hour, from: messageTime)
            let minute = calendar.component(.minute, from: messageTime)
            let zone: String
            let minutesString: String

            if hour < 12 {
                zone = "上午"
            } else {
                zone = "下午"
                hour -= 12
            }

            if minute < 10 {
                minutesString = "0\(minute)"
            } else {
                minutesString = "\(minute)"
            }

            return "\(zone) \(hour):\(minutesString)"

        // 七天內顯示星期幾
        } else if timeInterval < 60.0 * 60.0 * 24.0 * 7.0  {
            return "\(calendar.component(.weekday, from: messageTime))"
        // 其餘顯示幾月幾號
        } else {
            return "\(calendar.component(.month, from: messageTime))/\(calendar.component(.day, from: messageTime))"
        }
    }
}

extension TimeInterval {
    func convertToString(from timeInterval: TimeInterval) -> String {
        if timeInterval < 60 {
            return "\(Int(timeInterval)) 秒前"
        } else if timeInterval < 60.0 * 60.0 {
            return "\(timeInterval.asMinutes()) 分鐘前"
        } else if timeInterval < 60.0 * 60.0 * 24.0 {
            return "\(timeInterval.asHours()) 小時前"
        } else if timeInterval < 60.0 * 60.0 * 24.0 * 7.0 {
            return "\(timeInterval.asDays()) 天前"
        } else if timeInterval < 60.0 * 60.0 * 24.0 * 30.4369 {
            return "\(timeInterval.asWeeks()) 星期前"
        } else if timeInterval < 60.0 * 60.0 * 24.0 * 365.2422 {
            return "\(timeInterval.asMonths()) 月前"
        } else {
            return "\(timeInterval.asYears()) 年前"
        }
    }

    func asMinutes() -> Int { return Int(self / (60.0)) }
    func asHours() -> Int { return Int(self / (60.0 * 60.0)) }
    func asDays() -> Int { return Int(self / (60.0 * 60.0 * 24.0)) }
    func asWeeks() -> Int { return Int(self / (60.0 * 60.0 * 24.0 * 7.0)) }
    func asMonths() -> Int { return Int(self / (60.0 * 60.0 * 24.0 * 30.4369)) }
    func asYears() -> Int { return Int(self / (60.0 * 60.0 * 24.0 * 365.2422)) }
}
