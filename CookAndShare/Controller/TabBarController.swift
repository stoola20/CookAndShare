//
//  TabBarController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/14.
//

import UIKit
import FirebaseAuth

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard
            var viewControllers = self.viewControllers
        else { return }
        if Auth.auth().currentUser != nil,
            viewController == viewControllers[2] || viewController == viewControllers[4] {
            print("User is signed in.")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard
                let tabController = storyboard.instantiateViewController(withIdentifier: String(describing: TabBarController.self))
                    as? TabBarController,
                let tabBarControllers = tabController.viewControllers
            else { fatalError("Could not instantiate tabController") }
            viewControllers.replaceSubrange(2...2, with: [tabBarControllers[2]])
            viewControllers.replaceSubrange(4...4, with: [tabBarControllers[4]])
        } else {
            print("No user is signed in.")
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                    as? LoginViewController
            else { fatalError("Could not instantiate LoginViewController") }
            if viewController == viewControllers[2] {
                loginVC.tabBarItem = UITabBarItem(title: "訊息", image: UIImage(named: "chat_gray_25"), selectedImage: UIImage(named: "chat"))
                viewControllers.replaceSubrange(2...2, with: [loginVC])
            } else {
                loginVC.tabBarItem = UITabBarItem(title: "個人", image: UIImage(named: "account_gray_25"), selectedImage: UIImage(named: "account_25"))
                viewControllers.replaceSubrange(4...4, with: [loginVC])
            }
        }
        self.viewControllers = viewControllers
    }
}
