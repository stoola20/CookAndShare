//
//  DetailRecipeViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/30.
//

import UIKit
import FirebaseAuth
import Hero
import SPAlert

enum DetailRecipeSection: CaseIterable {
    case banner
    case ingredient
    case procedure
}

class DetailRecipeViewController: UIViewController {
    typealias AlertActionHandler = (UIAlertAction) -> Void
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    var recipeId = ""
    private var imageOriginalHeight = CGFloat()
    private let firestoreManager = FirestoreManager.shared
    private var hasLiked = false
    private var hasSaved = false
    private var author: User?
    private var recipe: Recipe? {
        didSet {
            guard let recipe = recipe else { return }
            let docRef = FirestoreEndpoint.users.collectionRef.document(recipe.authorId)
            firestoreManager.getDocument(docRef) { [weak self] (result: Result<User?, Error>) in
                switch result {
                case .success(let author):
                    guard let self = self, let author = author else { return }
                    self.author = author
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
            hasLiked = recipe.likes.contains(Constant.getUserId())
            hasSaved = recipe.saves.contains(Constant.getUserId())
            imgView.loadImage(recipe.mainImageURL, placeHolder: UIImage(named: Constant.friedRice))
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageOriginalHeight = view.bounds.width * 3 / 4
        tableView.contentInset = UIEdgeInsets(top: imageOriginalHeight - 50, left: 0, bottom: 0, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance
        navigationItem.compactAppearance = barAppearance
        navigationController?.navigationBar.tintColor = .background
        fetchRecipe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let barAppearance = UINavigationBarAppearance()
        let backImage = UIImage(systemName: "chevron.backward")
        barAppearance.configureWithOpaqueBackground()
        barAppearance.backgroundColor = .lightOrange
        barAppearance.shadowColor = nil
        barAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.darkBrown as Any
        ]
        barAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        navigationController?.navigationBar.standardAppearance = barAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        navigationController?.navigationBar.tintColor = .darkBrown
    }

    // MARK: - Action
    @objc func saveRecipe() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(
                    withIdentifier: String(describing: LoginViewController.self)
                )
                as? LoginViewController
            else { fatalError("Could not create loginVC") }
            loginVC.isPresented = true
            present(loginVC, animated: true)
        } else {
            guard let recipe = recipe else { return }
            if !hasSaved {
                showSPAlert(message: "收藏成功")
            }
            firestoreManager.updateRecipeSaves(
                recipeId: recipe.recipeId,
                userId: Constant.getUserId(),
                hasSaved: hasSaved
            )
            firestoreManager.updateUserSaves(
                recipeId: recipe.recipeId,
                userId: Constant.getUserId(),
                hasSaved: hasSaved
            )
            hasSaved.toggle()
        }
    }

    @objc func likeRecipe() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard let loginVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: LoginViewController.self)
            ) as? LoginViewController
            else { fatalError("Could not create loginVC") }
            loginVC.isPresented = true
            present(loginVC, animated: true)
        } else {
            guard let recipe = recipe else { return }
            firestoreManager.updateRecipeLikes(
                recipeId: recipe.recipeId,
                userId: Constant.getUserId(),
                hasLiked: hasLiked
            )
            hasLiked.toggle()
        }
    }

    // MARK: - Private methods
    private func setUpTableView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.registerCellWithNib(identifier: DetailBannerCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: DetailIngredientCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: DetailProcedureCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: IngredientHeaderCell.identifier, bundle: nil)
        tableView.registerCellWithNib(identifier: ProcedureHeaderCell.identifier, bundle: nil)
    }

    private func fetchRecipe() {
        let docRef = FirestoreEndpoint.recipes.collectionRef.document(recipeId)
        firestoreManager.getDocument(docRef) { [weak self] (result: Result<Recipe?, Error>) in
            switch result {
            case .success(let recipe):
                guard let self = self, let recipe = recipe else { return }
                self.recipe = recipe
            case .failure(let error):
                SPAlert.present(title: error.localizedDescription, preset: .error)
            }
        }
    }

    private func showSPAlert(message: String) {
        let alertView = SPAlertView(message: message)
        alertView.duration = 0.8
        alertView.present()
    }

    private func presentAlertController(alertTitle: String, alertMessage: String, confirmTitle: String, cancelTitle: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .actionSheet
        )
        let confirmAction = UIAlertAction(title: confirmTitle, style: .destructive, handler: handler)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }

    private func updateFirestore() {
        guard let recipe = self.recipe else { return }
        firestoreManager.deleteRecipePost(recipeId: recipe.recipeId)
        firestoreManager.updateUserRecipePost(
            recipeId: recipe.recipeId,
            userId: recipe.authorId,
            isNewPost: false
        )

        let query = FirestoreEndpoint.users.collectionRef
        firestoreManager.getDocuments(query) { [weak self] (result: Result<[User], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                users.forEach { user in
                    self.firestoreManager.updateUserSaves(recipeId: recipe.recipeId, userId: user.id, hasSaved: true)
                }
            case .failure(let error):
                self.showSPAlert(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - DetailBannerCellDelegate
extension DetailRecipeViewController: DetailBannerCellDelegate {
    func goToProfile(_ userId: String) {
        let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
        guard
            let publicProfileVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: PublicProfileViewController.self)
            )
            as? PublicProfileViewController
        else { fatalError("Could not create publicProfileVC") }
        publicProfileVC.userId = userId
        navigationController?.pushViewController(publicProfileVC, animated: true)
    }

    func deletePost() {
        let handler: AlertActionHandler = { [weak self] _ in
            guard let self = self else { return }
            self.showSPAlert(message: "刪除中")
            self.updateFirestore()
            self.navigationController?.popViewController(animated: true)
        }
        presentAlertController(
            alertTitle: "確定刪除此貼文？",
            alertMessage: "此動作將無法回復。",
            confirmTitle: "確定刪除",
            cancelTitle: "取消",
            handler: handler
        )
    }

    func editPost() {
        let storyboard = UIStoryboard(name: Constant.newpost, bundle: nil)
        guard
            let newRecipeVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: NewRecipeViewController.self)
            )
                as? NewRecipeViewController,
            let recipe = recipe
        else { fatalError("Cpuld not instantiate newRecipeVC") }
        newRecipeVC.recipe = recipe
        navigationController?.pushViewController(newRecipeVC, animated: true)
    }

    func block(user: User) {
        let handler: AlertActionHandler = { [weak self] _ in
            guard let self = self else { return }
            self.firestoreManager.updateUserBlocklist(userId: Constant.getUserId(), blockId: user.id, hasBlocked: false)
            self.navigationController?.popToRootViewController(animated: true)
        }

        presentAlertController(
            alertTitle: "封鎖\(user.name)？",
            alertMessage: "你將不會看到他的貼文、個人檔案或來自他的訊息。你封鎖用戶時，對方不會收到通知。",
            confirmTitle: "確定封鎖",
            cancelTitle: "取消",
            handler: handler
        )
    }

    func reportRecipe() {
        let handler: AlertActionHandler = { [weak self] _ in
            guard let self = self else { return }
            self.firestoreManager.updateRecipeReports(recipeId: self.recipeId, userId: Constant.getUserId())
            SPAlert.present(message: "謝謝你告知我們，我們會在未來減少顯示這類內容", haptic: .success)
        }

        presentAlertController(
            alertTitle: "檢舉這則貼文？",
            alertMessage: "你的檢舉將會匿名。",
            confirmTitle: "確定檢舉",
            cancelTitle: "取消",
            handler: handler
        )
    }
}

// MARK: - UITableViewDataSource
extension DetailRecipeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        DetailRecipeSection.allCases.count + 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipe = recipe else { return 0 }
        switch section {
        case 0, 1, 3:
            return 1
        case 2:
            return recipe.ingredients.count
        default:
            return recipe.procedures.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipe = recipe else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: DetailBannerCell.identifier, for: indexPath)
                    as? DetailBannerCell,
                let author = author
            else { fatalError("Could not create banner cell") }
            cell.delegate = self
            cell.layoutCell(with: recipe, author: author)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: IngredientHeaderCell.identifier, for: indexPath
            ) as? IngredientHeaderCell
            else { fatalError("Could not create header cell") }
            cell.layoutHeader(with: recipe)
            cell.viewController = self
            return cell

        case 2:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailIngredientCell.identifier, for: indexPath
            ) as? DetailIngredientCell
            else { fatalError("Could not create ingredient cell") }
            cell.layoutCell(with: recipe.ingredients[indexPath.row])
            return cell

        case 3:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: ProcedureHeaderCell.identifier)
                    as? ProcedureHeaderCell
            else { fatalError("Could not create header cell") }
            return cell

        default:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: DetailProcedureCell.identifier, for: indexPath)
                    as? DetailProcedureCell
            else { fatalError("Could not create procedure cell") }
            cell.viewController = self
            cell.procedureImageView.hero.id = "\(indexPath.section)\(indexPath.row)"
            cell.layoutCell(with: recipe.procedures[indexPath.row], at: indexPath)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension DetailRecipeViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let originalOffsetY = -(imageOriginalHeight - 50)
        let moveDistance = abs(scrollView.contentOffset.y - originalOffsetY)
        if scrollView.contentOffset.y < originalOffsetY {
            self.imgHeightConstraint.constant = imageOriginalHeight + moveDistance
            tableView.backgroundColor = .clear
        } else {
            self.imgHeightConstraint.constant = imageOriginalHeight - moveDistance / 2
            tableView.backgroundColor = UIColor(white: 0, alpha: moveDistance * 1.5 / imageOriginalHeight)
        }
    }

    func willAddIngredient() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
            guard
                let loginVC = storyboard.instantiateViewController(
                    withIdentifier: String(describing: LoginViewController.self)
                )
                    as? LoginViewController
            else { fatalError("Could not create loginVC") }
            loginVC.isPresented = true
            present(loginVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
            guard
                let addToListVC = storyboard.instantiateViewController(
                    withIdentifier: String(describing: AddToShoppingListVC.self)
                )
                    as? AddToShoppingListVC,
                let recipe = recipe
            else { fatalError("Could not create AddToShoppingListVC") }
            addToListVC.initialIngredients = recipe.ingredients
            present(addToListVC, animated: true)
        }
    }
}
