//
//  DateHelper.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/1.
//

import Foundation
import AVKit

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

        var hour = calendar.component(.hour, from: messageTime)
        let minute = calendar.component(.minute, from: messageTime)
        let zone: String
        let minutesString: String

        if hour < 12 {
            zone = "上午"
        } else if hour == 12 {
            zone = "下午"
        } else {
            zone = "下午"
            hour -= 12
        }

        minutesString = minute < 10 ? "0\(minute)" : "\(minute)"

        return "\(zone) \(hour):\(minutesString)"
    }

    static func getChatRoomTimeString(from messageTime: Date) -> String {
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
            } else if hour == 12 {
                zone = "下午"
            } else {
                zone = "下午"
                hour -= 12
            }

            minutesString = minute < 10 ? "0\(minute)" : "\(minute)"

            return "\(zone) \(hour):\(minutesString)"

        // 七天內顯示星期幾
        } else if timeInterval < 60.0 * 60.0 * 24.0 * 7.0 {
            var weekday: String
            switch calendar.component(.weekday, from: messageTime) {
            case 1: weekday = "星期日"
            case 2: weekday = "星期一"
            case 3: weekday = "星期二"
            case 4: weekday = "星期三"
            case 5: weekday = "星期四"
            case 6: weekday = "星期五"
            default: weekday = "星期六"
            }
            return "\(weekday)"
        // 其餘顯示幾月幾號
        } else {
            return "\(calendar.component(.month, from: messageTime))/\(calendar.component(.day, from: messageTime))"
        }
    }

    func getSharePostTime(from date: Date) -> String {
        let calendar = Calendar.current
        let timeInterval = Date() - date
        if timeInterval < 60 {
            return "\(Int(timeInterval)) 秒前"
        } else if timeInterval < 60.0 * 60.0 {
            return "\(timeInterval.asMinutes()) 分鐘前"
        } else if timeInterval < 60.0 * 60.0 * 24.0 {
            return "\(timeInterval.asHours()) 小時前"
        } else if timeInterval < 60.0 * 60.0 * 24.0 * 7.0 {
            return "\(timeInterval.asDays()) 天前"
        } else {
            return "\(calendar.component(.month, from: date))月\(calendar.component(.day, from: date))日"
        }
    }
}

extension TimeInterval {
    func asMinutes() -> Int { return Int(self / (60.0)) }
    func asHours() -> Int { return Int(self / (60.0 * 60.0)) }
    func asDays() -> Int { return Int(self / (60.0 * 60.0 * 24.0)) }

    func audioDurationString() -> String {
        let sec = Int(self.truncatingRemainder(dividingBy: 60.0))
        let minute = Int(self / 60.0)
        let secString = sec < 10 ? "0\(sec)" : "\(sec)"
        let minuteString = minute < 10 ? "0\(minute)" : "\(minute)"

        return "\(minuteString):\(secString)"
    }
}
