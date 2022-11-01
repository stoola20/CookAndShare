//
//  FirestoreManager.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

typealias RecipeResponse = (Result<[Recipe], Error>) -> Void

struct FirestoreManager {
    static let shared = FirestoreManager()
    let recipesCollection = Firestore.firestore().collection(Constant.firestoreRecipes)
    let usersCollection = Firestore.firestore().collection(Constant.firestoreUsers)
    let sharesCollection = Firestore.firestore().collection(Constant.firestoreShares)
    let storage = Storage.storage()

// MARK: - Upload Photo
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = storage.reference().child(UUID().uuidString + ".jpg")
        if let data = image.jpegData(compressionQuality: 0.3) {
            fileReference.putData(data, metadata: nil) { result in
                switch result {
                case .success:
                    fileReference.downloadURL(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

// MARK: - Recipe
    func addNewRecipe(_ recipe: Recipe, to document: DocumentReference) {
        do {
            try document.setData(from: recipe)
            print("Document added with ID: \(document.documentID)")
        } catch let error {
            print("Error adding document: \(error)")
        }
    }


    func searchRecipe(type: SearchType, query: String, completion: @escaping RecipeResponse) {
        switch type {
        case .title:
            searchRecipeTitle(query, completion: completion)
        case .ingredient, .camera:
            searchIngredientName(query, completion: completion)
        case .random:
            searchAllRecipes(completion: completion)
        }
    }

    func searchAllRecipes(completion: @escaping RecipeResponse) {
        var recipes: [Recipe] = []

        recipesCollection.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
            } else {
                guard let querySnapshot = querySnapshot else { return }
                querySnapshot.documents.forEach { document in
                    do {
                        let recipe = try document.data(as: Recipe.self)
                        recipes.append(recipe)
                    } catch {
                        print(error)
                    }
                }
                completion(.success(recipes))
            }
        }
    }

    func searchRecipesById(_ recipeId: String, completion: @escaping (Result<Recipe, Error>) -> Void) {
        recipesCollection.whereField("recipeId", isEqualTo: recipeId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting users: \(error)")
                completion(.failure(error))
            } else {
                guard
                    let querySnapshot = querySnapshot,
                    let document = querySnapshot.documents.first
                else { return }

                do {
                    let recipe = try document.data(as: Recipe.self)
                    completion(.success(recipe))
                } catch {
                    print(error)
                }
            }
        }
    }

    func searchRecipeTitle(_ title: String, completion: @escaping RecipeResponse) {
        var recipes: [Recipe] = []
        recipesCollection.whereField(Constant.title, isEqualTo: title).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
            } else {
                guard let querySnapshot = querySnapshot else { return }
                querySnapshot.documents.forEach { document in
                    do {
                        let recipe = try document.data(as: Recipe.self)
                        recipes.append(recipe)
                    } catch {
                        print(error)
                    }
                }
                completion(.success(recipes))
            }
        }
    }

    func searchIngredientName(_ name: String, completion: @escaping RecipeResponse) {
        var recipes: [Recipe] = []
        recipesCollection
            .whereField(Constant.ingredientNames, arrayContains: name)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(.failure(error))
                } else {
                    guard let querySnapshot = querySnapshot else { return }
                    querySnapshot.documents.forEach { document in
                        do {
                            let recipe = try document.data(as: Recipe.self)
                            recipes.append(recipe)
                        } catch {
                            print(error)
                        }
                    }
                    completion(.success(recipes))
                }
            }
    }

    func updateRecipeLikes(recipeId: String, userId: String, hasLiked: Bool) {
        let recipeRef = recipesCollection.document(recipeId)
        if hasLiked {
            recipeRef.updateData([
                Constant.likes: FieldValue.arrayRemove([userId])
            ])
        } else {
            recipeRef.updateData([
                Constant.likes: FieldValue.arrayUnion([userId])
            ])
        }
    }

    func updateRecipeSaves(recipeId: String, userId: String, hasSaved: Bool) {
        let recipeRef = recipesCollection.document(recipeId)
        if hasSaved {
            recipeRef.updateData([
                Constant.saves: FieldValue.arrayRemove([userId])
            ])
        } else {
            recipeRef.updateData([
                Constant.saves: FieldValue.arrayUnion([userId])
            ])
        }
    }

// MARK: - User
    func updateUserRecipePost(recipeId: String, userId: String) {
        let userRef = usersCollection.document(userId)
        userRef.updateData([
            Constant.recipesId: FieldValue.arrayUnion([recipeId])
        ])
    }

    func updateUserSaves(recipeId: String, userId: String, hasSaved: Bool) {
        let userRef = usersCollection.document(userId)
        if hasSaved {
            userRef.updateData([
                Constant.savedRecipesId: FieldValue.arrayRemove([recipeId])
            ])
        } else {
            userRef.updateData([
                Constant.savedRecipesId: FieldValue.arrayUnion([recipeId])
            ])
        }
    }

    func updateUserSharePost(shareId: String, userId: String) {
        let userRef = usersCollection.document(userId)
        userRef.updateData([
            Constant.sharesId: FieldValue.arrayUnion([shareId])
        ])
    }

    func fetchUserData(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        usersCollection.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting users: \(error)")
                completion(.failure(error))
            } else {
                guard
                    let querySnapshot = querySnapshot,
                    let document = querySnapshot.documents.first
                else { return }

                do {
                    let user = try document.data(as: User.self)
                    completion(.success(user))
                } catch {
                    print(error)
                }
            }
        }
    }

// MARK: - Share
    func addNewShare(_ share: Share, to document: DocumentReference) {
        do {
            try document.setData(from: share)
            print("Document added with ID: \(document.documentID)")
        } catch let error {
            print("Error adding document: \(error)")
        }
    }

    func fetchSharePost(completion: @escaping (Result<[Share], Error>) -> Void) {
        var shares: [Share] = []

        sharesCollection.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
            } else {
                guard let querySnapshot = querySnapshot else { return }
                querySnapshot.documents.forEach { document in
                    do {
                        let recipe = try document.data(as: Share.self)
                        if Double(recipe.dueDate.seconds) < Date().timeIntervalSince1970 {
                            deleteSharePost(shareId: recipe.shareId)
                        } else {
                            shares.append(recipe)
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(shares))
            }
        }
    }

    func deleteSharePost(shareId: String) {
        sharesCollection.document(shareId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
