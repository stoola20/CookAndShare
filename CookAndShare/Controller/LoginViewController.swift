//
//  LoginViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/14.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController {
    private var currentNonce: String?
    let firestoreManager = FirestoreManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setSignInWithAppleBtn()
    }

    // MARK: - 在畫面上產生 Sign in with Apple 按鈕
    func setSignInWithAppleBtn() {
        let signInWithAppleBtn = ASAuthorizationAppleIDButton(
            authorizationButtonType: .continue,
            authorizationButtonStyle: .black
        )
        view.addSubview(signInWithAppleBtn)
        signInWithAppleBtn.cornerRadius = 10
        signInWithAppleBtn.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        signInWithAppleBtn.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signInWithAppleBtn.widthAnchor.constraint(equalToConstant: 280).isActive = true
        signInWithAppleBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInWithAppleBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
    }

    @objc func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }
        .joined()

        return hashString
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )

            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                if error != nil {
                    guard let error = error else { return }
                    print(error.localizedDescription)
                    return
                }

                // User is signed in to Firebase with Apple.
                guard
                    let authResult = authResult,
                    let fcmToken: String = UserDefaults.standard.object(forKey: "fcmToken") as? String
                else { return }
                self.firestoreManager.isNewUser(id: authResult.user.uid) { result in
                    switch result {
                    case .success(let isNewUser):
                        if !isNewUser {
                            self.firestoreManager.updateFCMToken(userId: Constant.getUserId(), fcmToken: fcmToken)
                        } else {
                            guard let fullName = appleIDCredential.fullName else { return }
                            let user = User(
                                id: authResult.user.uid,
                                name: "\(fullName.familyName ?? "")\(fullName.givenName ?? "")",
                                email: authResult.user.email ?? "",
                                imageURL: authResult.user.photoURL?.absoluteString ?? "",
                                fcmToken: fcmToken,
                                recipesId: [],
                                savedRecipesId: [],
                                sharesId: [],
                                conversationId: []
                            )
                            self.firestoreManager.createUser(id: authResult.user.uid, user: user)
                        }

                    case .failure(let error):
                        print(error)
                    }
                }

                print("成功以 Apple 登入 Firebase")
                let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
                guard
                    let profileVC = storyboard.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self))
                        as? ProfileViewController
                else { fatalError("Could not instantiate profileVC") }
                let navigationVC = UINavigationController(rootViewController: profileVC)
                navigationVC.tabBarItem = UITabBarItem(title: "個人", image: UIImage(systemName: "person.circle"), tag: 3)
                navigationVC.navigationBar.tintColor = UIColor.darkBrown
                var arrayChildViewControllers = self.tabBarController?.viewControllers
                if let selectedTabIndex = self.tabBarController?.selectedIndex {
                    arrayChildViewControllers?.replaceSubrange(selectedTabIndex...selectedTabIndex, with: [navigationVC])
                }
                self.tabBarController?.viewControllers = arrayChildViewControllers
                self.dismiss(animated: true)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登入失敗，處理 Error
        switch error {
        case ASAuthorizationError.canceled:
            print("使用者取消登入")
        case ASAuthorizationError.failed:
            print("授權請求失敗")
        case ASAuthorizationError.invalidResponse:
            print("授權請求無回應")
        case ASAuthorizationError.notHandled:
            print("授權請求未處理")
        case ASAuthorizationError.unknown:
            print("授權失敗，原因不知")
        default:
            break
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
// 在畫面上顯示授權畫面
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
