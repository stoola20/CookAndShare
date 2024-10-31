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
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
            // For iOS 10 data message (sent via FCM)
        } else {
            let settings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        Messaging.messaging().delegate = self
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

        if let tabBarController = rootViewController as? TabBarController {
            tabBarController.selectedIndex = 2
            if let navController = tabBarController.selectedViewController as? UINavigationController {
                navController.popToRootViewController(animated: false)
            }
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.getNotificationSettings { settings in
            if settings.soundSetting == .enabled {
                completionHandler([.banner, .badge, .sound])
            } else {
                completionHandler([.banner, .badge])
            }
        }
    }
}
