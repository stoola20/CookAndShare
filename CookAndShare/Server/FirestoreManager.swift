//
//  FirestoreManager.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

struct FirestoreManager {
    static let shared = FirestoreManager()
    let recipesCollection = Firestore.firestore().collection(Constant.firestoreRecipes)
    let storage = Storage.storage()
    
    func addNewRecipe(_ recipe: Recipe, to document: DocumentReference) {
        do {
            try document.setData(from: recipe)
            print("Document added with ID: \(document.documentID)")
        } catch (let error) {
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
    
    func downloadRecipe(completion: @escaping (Result<[Recipe], Error>) -> Void) {
        var recipes = [Recipe]()

        recipesCollection.getDocuments { (guerySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
            } else {
                guard let querySnapshot = guerySnapshot else { return }
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
    
    func searchRecipe(type: SearchType, completion: @escaping (Result<[Recipe], Error> -> Void) {
        
    }
}
