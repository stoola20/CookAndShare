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
import Lottie
import SPAlert

class LoginViewController: UIViewController {
    private var currentNonce: String?
    let firestoreManager = FirestoreManager.shared
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var animationViews: [LottieAnimationView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        setSignInWithAppleBtn()
        scrollView.delegate = self
        setUpUI()
    }

    func setUpUI() {
        titleLabel.textColor = UIColor.darkBrown
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.text = "分享"
        descriptionLabel.textColor = UIColor.darkBrown
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.text = "與其他用戶分享美味食譜和食材"
        for animationView in animationViews {
            animationView.clipsToBounds = true
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.animationSpeed = 1
            animationView.play()
        }
        animationViews[0].play()
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
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard
                    let tabController = storyboard.instantiateViewController(withIdentifier: String(describing: TabBarController.self))
                        as? TabBarController,
                    let tabBarControllers = tabController.viewControllers
                else { fatalError("Could not instantiate tabController") }

                var childViewControllers = self.tabBarController?.viewControllers

                childViewControllers?.replaceSubrange(3...3, with: [tabBarControllers[3]])
                self.tabBarController?.viewControllers = childViewControllers
                self.dismiss(animated: true)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登入失敗，處理 Error
        switch error {
        case ASAuthorizationError.canceled:
            SPAlert.present(message: "使用者取消登入", haptic: .error)
        case ASAuthorizationError.failed:
            SPAlert.present(message: "授權請求失敗", haptic: .error)
        case ASAuthorizationError.invalidResponse:
            SPAlert.present(message: "授權請求無回應", haptic: .error)
        case ASAuthorizationError.notHandled:
            SPAlert.present(message: "授權請求未處理", haptic: .error)
        case ASAuthorizationError.unknown:
            SPAlert.present(message: "授權失敗，原因不明", haptic: .error)
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

// MARK: - UIScrollViewDelegate
extension LoginViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        pageControl.currentPage = Int(page)
        for animationView in animationViews {
            animationView.stop()
        }
        animationViews[Int(page)].play()
        switch page {
        case 0:
            titleLabel.text = "分享"
            descriptionLabel.text = "與用戶分享您的拿手料理和食材"
        case 1:
            titleLabel.text = "通訊"
            descriptionLabel.text = "藉由通訊功能與用戶交換食材及討論料理想法"
        case 2:
            titleLabel.text = "採買清單"
            descriptionLabel.text = "直接從食譜添加至採買清單，\n成為您的廚房小幫手"
        default:
            titleLabel.text = "儲存食譜"
            descriptionLabel.text = "記錄您喜歡的食譜，可跨裝置同步"
        }
    }
}
