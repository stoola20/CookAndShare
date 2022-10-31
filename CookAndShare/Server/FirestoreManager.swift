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
    let storage = Storage.storage()

    func addNewRecipe(_ recipe: Recipe, to document: DocumentReference) {
        do {
            try document.setData(from: recipe)
            print("Document added with ID: \(document.documentID)")
        } catch let error {
            print("Error adding document: \(error)")
        }
    }

    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = storage.reference().child(UUID().uuidString + ".jpg")
        if let data = image.jpegData(compressionQuality: 0.9) {
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
}
