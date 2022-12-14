//
//  AppDelegate.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import UIKit
import FirebaseMessaging
import FirebaseCore
import GoogleMaps
import GooglePlaces
import IQKeyboardManager
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let pushManager = PushNotificationManager(userID: Constant.getUserId())
        pushManager.registerForPushNotifications()

        GMSServices.provideAPIKey(APIKey.apiKey)
        GMSPlacesClient.provideAPIKey(APIKey.apiKey)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().toolbarDoneBarButtonItemText = "完成"
        IQKeyboardManager.shared().disabledToolbarClasses.add(ChatRoomViewController.self)
        IQKeyboardManager.shared().disabledToolbarClasses.add(SearchViewController.self)

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .lightOrange
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.darkBrown as Any
        ]
        navigationBarAppearance.shadowColor = nil
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        UITabBar.appearance().tintColor = UIColor.myOrange
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("") {
            return $0 + String(format: "%02x", $1)
        }
        print("deviceTokenString: \(deviceTokenString)")
        Messaging.messaging().apnsToken = deviceToken
        let pushManager = PushNotificationManager(userID: Constant.getUserId())
        pushManager.updateFirestorePushTokenIfNeeded()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("error: \(error)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
