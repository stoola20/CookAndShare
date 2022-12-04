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
        guard let url = NSURL(string: urlString) else { return }
        let paramString: [String: Any] = [
            "to": token,
            "priority": "high",
            "notification": ["title": title, "body": body],
            "data": ["user": "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(APIKey.serverKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, _ in
            do {
                if let jsonData = data {
                    print(jsonData)
                    if let jsonDataDict = try JSONSerialization.jsonObject(
                        with: jsonData,
                        options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
