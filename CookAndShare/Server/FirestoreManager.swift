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
    let conversationsCollection = Firestore.firestore().collection(Constant.firestoreConversations)
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

    func handleAudioSendWith(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = storage.reference().child(UUID().uuidString + ".m4a")
        fileReference.putFile(from: url, metadata: nil, completion: { _, error in
            if error != nil {
                print(error as Any)
            } else {
                fileReference.downloadURL(completion: completion)
            }
        })
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

    func addRecipeListener(completion: @escaping RecipeResponse) {
        var recipes: [Recipe] = []

        recipesCollection.addSnapshotListener { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else {
                print("Error fetching document: \(String(describing: error))")
                return
            }
            documentSnapshot.documents.forEach { document in
                guard let recipe = try? document.data(as: Recipe.self) else {
                    print("Document data was empty.")
                    return
                }
                recipes.append(recipe)
            }
            completion(.success(recipes))
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

    func fetchRecipeBy(_ id: String, completion: @escaping (Result<Recipe, Error>) -> Void) {
        recipesCollection.whereField("recipeId", isEqualTo: id).getDocuments { querySnapshot, error in
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
                    completion(.failure(error))
                }
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
    func createUser(id: String, user: User) {
        do {
            try usersCollection.document(id).setData(from: user)
            print("Document added with ID: \(id)")
        } catch let error {
            print("Error adding document: \(error)")
        }
    }

    func isNewUser(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        usersCollection.document(id).getDocument { document, _ in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                completion(.success(false))
            } else {
                print("Document does not exist")
                completion(.success(true))
            }
        }
    }

    func updateUserName(userId: String, name: String) {
        usersCollection.document(userId).setData(["name": name], merge: true)
    }

    func updateUserPhoto(userId: String, imageURL: String) {
        usersCollection.document(userId).setData(["imageURL": imageURL], merge: true)
    }

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

    func updateUserSharePost(shareId: String, userId: String, isNewPost: Bool) {
        let userRef = usersCollection.document(userId)
        if isNewPost {
            userRef.updateData([
                Constant.sharesId: FieldValue.arrayUnion([shareId])
            ])
        } else {
            userRef.updateData([
                Constant.sharesId: FieldValue.arrayRemove([shareId])
            ])
        }
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

    func updateUserConversation(userId: String, friendId: String, channelId: String) {
        usersCollection.document(userId).updateData([
            Constant.conversationId: FieldValue.arrayUnion([channelId])
        ])
        usersCollection.document(friendId).updateData([
            Constant.conversationId: FieldValue.arrayUnion([channelId])
        ])
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
                        let share = try document.data(as: Share.self)
                        let shareTimeInterval = Double(share.dueDate.seconds)
                        let shareDayComponent = Calendar.current.component(.day, from: Date(timeIntervalSince1970: shareTimeInterval))
                        let today = Calendar.current.component(.day, from: Date())
                        if shareTimeInterval < Date().timeIntervalSince1970 && shareDayComponent != today {
                            deleteSharePost(shareId: share.shareId)
                            updateUserSharePost(shareId: share.shareId, userId: share.authorId, isNewPost: false)
                        } else {
                            shares.append(share)
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(shares))
            }
        }
    }

    func fetchShareBy(_ id: String, completion: @escaping (Result<Share, Error>) -> Void) {
        sharesCollection.whereField("shareId", isEqualTo: id).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting users: \(error)")
                completion(.failure(error))
            } else {
                guard
                    let querySnapshot = querySnapshot,
                    let document = querySnapshot.documents.first
                else { return }

                do {
                    let share = try document.data(as: Share.self)
                    completion(.success(share))
                } catch {
                    completion(.failure(error))
                }
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

// MARK: - Chat
    func fetchConversation(with friendId: String, completion: @escaping (Result<Conversation?, Error>) -> Void) {
        conversationsCollection.whereField("friendIds", arrayContains: friendId).getDocuments { querySnapshot, _ in
            guard let querySnapshot = querySnapshot else { return }
            var conversation: Conversation? = nil
            if querySnapshot.isEmpty {
                print("querySnapshot.isEmpty")
                completion(.success(conversation))
            } else {
                querySnapshot.documents.forEach { document in
                    do {
                        let conversationData = try document.data(as: Conversation.self)
                        if conversationData.friendIds == [friendId, Constant.getUserId()] || conversationData.friendIds == [Constant.getUserId(), friendId] {
                            conversation = conversationData
                        } else {
                            print("conversation not found!")
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(conversation))
            }
        }
    }

    func fetchConversationBy(_ id: String, completion: @escaping (Result<Conversation, Error>) -> Void) {
        conversationsCollection.whereField("channelId", isEqualTo: id).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting users: \(error)")
                completion(.failure(error))
            } else {
                guard
                    let querySnapshot = querySnapshot,
                    let document = querySnapshot.documents.first
                else { return }

                do {
                    let conversation = try document.data(as: Conversation.self)
                    completion(.success(conversation))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    func createNewConversation(_ conversation: Conversation, to document: DocumentReference) {
        do {
            try document.setData(from: conversation)
            print("Document added with ID: \(document.documentID)")
        } catch let error {
            print("Error adding document: \(error)")
        }
    }

    func updateConversation(channelId: String, message: [String: Any]) {
        let conversationRef = conversationsCollection.document(channelId)
        conversationRef.updateData([
            "messages": FieldValue.arrayUnion([message])
        ])
    }

    func addListener(channelId: String, completion: @escaping (Result<Conversation, Error>) -> Void) {
        let conversationRef = conversationsCollection.document(channelId)

        conversationRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }

            guard let newConversation = try? document.data(as: Conversation.self) else {
                print("Document data was empty.")
                return
            }

            completion(.success(newConversation))
        }
    }
}
