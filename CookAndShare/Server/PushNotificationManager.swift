//
//  PushNotificationManager.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/9.
//

import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String

    init(userID: String) {
        self.userID = userID
        super.init()
    }

    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }

    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            UserDefaults.standard.set(token, forKey: "fcmToken")
            print("Set fcmToken")
        }
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard
            let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .window?.rootViewController
        else { return }

        let storyboard = UIStoryboard(name: Constant.share, bundle: nil)
        if let chatListVC = storyboard.instantiateViewController(withIdentifier: String(describing: ChatListViewController.self)) as? ChatListViewController,
            let tabBarController = rootViewController as? TabBarController {
            tabBarController.selectedIndex = 1
            if let navController = tabBarController.selectedViewController as? UINavigationController {
                navController.pushViewController(chatListVC, animated: true)
            }
        }

        completionHandler()
    }

    // 讓 App 在前景也能顯示推播
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }
}
