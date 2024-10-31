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
import SafariServices
import KeychainSwift
import SwiftJWT
import SwiftUI
import Alamofire

class LoginViewController: UIViewController {
    var isPresented = false
    private var currentNonce: String?
    private let firestoreManager = FirestoreManager.shared
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var animationViews: [LottieAnimationView]!
    @IBOutlet weak var privacyPolicy: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setSignInWithAppleBtn()
        scrollView.delegate = self
        setUpUI()
        privacyPolicy.isUserInteractionEnabled = true
        privacyPolicy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPrivacyPolicy)))
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
        }
        animationViews[0].play()
    }

    @objc func openPrivacyPolicy() {
        guard let url = URL(string: "https://www.privacypolicies.com/live/32b90ff9-1e31-4d0b-bb08-7ca320c11db9")
        else { return }

        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }

    // MARK: - 在畫面上產生 Sign in with Apple 按鈕
    func setSignInWithAppleBtn() {
        let signInWithAppleBtn = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: .black
        )
        view.addSubview(signInWithAppleBtn)
        signInWithAppleBtn.cornerRadius = 10
        signInWithAppleBtn.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        signInWithAppleBtn.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signInWithAppleBtn.widthAnchor.constraint(equalToConstant: 280).isActive = true
        signInWithAppleBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInWithAppleBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
    }

    @objc func signInWithApple() {
        let nonce = AuthManager.shared.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = AuthManager.shared.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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

            if let authorizationCode = appleIDCredential.authorizationCode,
                let codeString = String(data: authorizationCode, encoding: .utf8) {
                getRefreshToken(clientSecret: JWTManager.shared.makeJWT(), code: codeString)
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

                self.firestoreManager.isNewUser(id: authResult.user.uid) { isNewUser in
                    if !isNewUser {
                        self.firestoreManager.updateUserData(
                            userId: Constant.getUserId(),
                            field: Constant.fcmToken,
                            value: fcmToken
                        )
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
                            conversationId: [],
                            blockList: []
                        )
                        let userRef = FirestoreEndpoint.users.collectionRef.document(authResult.user.uid)
                        self.firestoreManager.setData(user, to: userRef)
                    }
                    print("成功以 Apple 登入 Firebase")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard
                        let tabController = storyboard.instantiateViewController(
                            withIdentifier: String(describing: TabBarController.self)
                        )
                            as? TabBarController,
                        let tabBarControllers = tabController.viewControllers
                    else { fatalError("Could not instantiate tabController") }
                    if self.isPresented {
                        UserDefaults.standard.set(false, forKey: "normalAppearance")
                    } else {
                        UserDefaults.standard.set(true, forKey: "normalAppearance")
                    }
                    var childViewControllers = self.tabBarController?.viewControllers
                    childViewControllers?.replaceSubrange(2...2, with: [tabBarControllers[2]])
                    childViewControllers?.replaceSubrange(4...4, with: [tabBarControllers[4]])
                    self.tabBarController?.viewControllers = childViewControllers
                    self.dismiss(animated: true)
                }
            }
        }
    }

    func getRefreshToken(clientSecret: String, code: String) {
        let paramString: [String: Any] = [
            "client_id": JWTManager.shared.bundleId,
            "client_secret": clientSecret,
            "code": code,
            "grant_type": "authorization_code"
        ]

        let headers: HTTPHeaders = [.contentType("application/x-www-form-urlencoded")]

        guard
            let url = URL(string: JWTManager.shared.tokenEndpoint)
        else { return }
        AF.request(
            url,
            method: .post,
            parameters: paramString,
            headers: headers
        )
        .responseDecodable(of: RefreshResponse.self) { response in
            if let data = response.value {
                let keychain = KeychainSwift()
                keychain.set(data.refreshToken, forKey: "refreshToken")
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登入失敗，處理 Error
        switch error {
        case ASAuthorizationError.canceled:
            AlertKitAPI.present(title: "使用者取消登入", style: .iOS17AppleMusic, haptic: .error)
        case ASAuthorizationError.failed:
            AlertKitAPI.present(title: "授權請求失敗", style: .iOS17AppleMusic, haptic: .error)
        case ASAuthorizationError.invalidResponse:
            AlertKitAPI.present(title: "授權請求無回應", style: .iOS17AppleMusic, haptic: .error)
        case ASAuthorizationError.notHandled:
            AlertKitAPI.present(title: "授權請求未處理", style: .iOS17AppleMusic, haptic: .error)
        case ASAuthorizationError.unknown:
            AlertKitAPI.present(title: "授權失敗，原因不明", style: .iOS17AppleMusic, haptic: .error)
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
