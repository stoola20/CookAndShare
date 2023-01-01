//
//  PushNotificationSender.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/9.
//

import UIKit
class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        guard let url = URL(string: urlString) else { return }
        let paramString: [String: Any] = [
            "to": token,
            "priority": "high",
            "notification": ["title": title, "body": body]
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(APIKey.serverKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            do {
                guard let jsonDataDict = try JSONSerialization.jsonObject(
                    with: data,
                    options: JSONSerialization.ReadingOptions.allowFragments
                )
                    as? [String: AnyObject]
                else { return }
                print("Received data:\n\(jsonDataDict))")
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
