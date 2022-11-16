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
        if var viewControllers = self.viewControllers,
            viewController == viewControllers[3] {
            if Auth.auth().currentUser != nil {
                print("User is signed in.")
                let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
                guard
                    let profileVC = storyboard.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self))
                        as? ProfileViewController
                else { fatalError("Could not instantiate profileVC") }
                let navController = UINavigationController(rootViewController: profileVC)
                navController.navigationBar.tintColor = UIColor.darkBrown
                navController.tabBarItem = UITabBarItem(title: "個人", image: UIImage(systemName: "person.circle"), tag: 3)
                viewControllers.replaceSubrange(3...3, with: [navController])
            } else {
                print("No user is signed in.")
                let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
                guard
                    let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                        as? LoginViewController
                else { fatalError("Could not instantiate LoginViewController") }
                loginVC.tabBarItem = UITabBarItem(title: "個人", image: UIImage(systemName: "person.circle"), tag: 3)
                viewControllers.replaceSubrange(3...3, with: [loginVC])
            }
            self.viewControllers = viewControllers
        }
    }
}
