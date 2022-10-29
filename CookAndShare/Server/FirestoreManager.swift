//
//  FirestoreManager.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import Foundation
import FirebaseFirestore

struct FirestoreManager {
    static let shared = FirestoreManager()
    let recipesCollection = Firestore.firestore().collection(Constant.firestoreRecipes)
    
    func addNewRecipe(_ recipe: Recipe, to document: DocumentReference) {
        do {
            try document.setData(from: recipe)
            print("Document added with ID: \(document.documentID)")
        } catch (let error) {
            print("Error adding document: \(error)")
        }
    }
    
}
