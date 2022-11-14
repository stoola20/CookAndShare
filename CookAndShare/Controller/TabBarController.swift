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

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let viewControllers = self.viewControllers,
            viewController == viewControllers[3] {
            if Auth.auth().currentUser != nil {
                print("User is signed in.")
                return true
            } else {
                print("No user is signed in.")
                let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
                guard
                    let loginVC = storyboard.instantiateViewController(withIdentifier: String(describing: LoginViewController.self))
                        as? LoginViewController
                else { fatalError("Could not instantiate LoginViewController") }

                loginVC.modalPresentationStyle = .overCurrentContext
                present(loginVC, animated: true)
                return false
            }
        }
        return true
    }
}
