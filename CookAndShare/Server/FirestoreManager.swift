//
//  FirestoreManager.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/29.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

typealias RecipeResponse = (Result<[Recipe], Error>) -> Void

enum FirestoreEndpoint {
    case recipes
    case shares
    case conversations
    case users

    var collectionRef: CollectionReference {
        let firestore = Firestore.firestore()

        switch self {
        case .recipes:
            return firestore.collection(Constant.firestoreRecipes)
        case .shares:
            return firestore.collection(Constant.firestoreShares)
        case .conversations:
            return firestore.collection(Constant.firestoreConversations)
        case .users:
            return firestore.collection(Constant.firestoreUsers)
        }
    }
}

// swiftlint:disable type_body_length
class FirestoreManager {
    static let shared = FirestoreManager()
    let recipesCollection = Firestore.firestore().collection(Constant.firestoreRecipes)
    let usersCollection = Firestore.firestore().collection(Constant.firestoreUsers)
    let sharesCollection = Firestore.firestore().collection(Constant.firestoreShares)
    let conversationsCollection = Firestore.firestore().collection(Constant.firestoreConversations)
    let storage = Storage.storage()

// MARK: - Private
    private func parseDucument<T: Codable>(snapshot: DocumentSnapshot?, error: Error?) -> T? {
        guard let snapshot = snapshot, snapshot.exists else {
            let errorMessage = error?.localizedDescription ?? ""
            print("DEBUG: Nil document", errorMessage)
            return nil
        }

        var model: T?
        do {
            model = try snapshot.data(as: T.self)
        } catch {
            print("DEBUG: Error: decoding\(T.self) data -", error.localizedDescription)
        }
        return model
    }

    private func parseDocuments<T: Codable>(snapshot: QuerySnapshot?, error: Error?) -> [T] {
        guard let snapshot = snapshot else {
            let errorMessage = error?.localizedDescription ?? ""
            print("DEBUG: Error feat hing snapshot -", errorMessage)
            return []
        }

        var models: [T] = []
        snapshot.documents.forEach { document in
            do {
                let item = try document.data(as: T.self)
                models.append(item)
            } catch {
                print("DEBUG: Error decoding \(T.self) data -", error.localizedDescription)
            }
        }
        return models
    }

// MARK: - Methods
    func getDocument<T: Codable>(_ docRef: DocumentReference, completion: @escaping (T?) -> Void) {
        docRef.getDocument { snapshot, error in
            completion(self.parseDucument(snapshot: snapshot, error: error))
        }
    }

    func getDocuments<T: Codable>(_ query: Query, completion: @escaping ([T]) -> Void) {
        query.getDocuments { snapshot, error in
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }

// MARK: - Upload Photo
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let resizedImage = image.resizeWithWidth(width: 1200) else { return }
        let fileReference = storage.reference().child(UUID().uuidString + ".jpg")
        if let data = resizedImage.jpegData(compressionQuality: 0.5) {
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
        fileReference.putFile(from: url, metadata: nil) { _, error in
            if error != nil {
                print(error as Any)
            } else {
                fileReference.downloadURL(completion: completion)
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

    func updateRecipeReports(recipeId: String, userId: String) {
        let recipeRef = recipesCollection.document(recipeId)
        recipeRef.updateData([
            "reports": FieldValue.arrayUnion([userId])
        ])
    }

    func deleteRecipePost(recipeId: String) {
        recipesCollection.document(recipeId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
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

    func isNewUser(id: String, completion: @escaping (Bool) -> Void) {
        usersCollection.document(id).getDocument { document, _ in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                completion(false)
            } else {
                print("Document does not exist")
                completion(true)
            }
        }
    }

    func searchAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        var users: [User] = []

        usersCollection.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
            } else {
                guard let querySnapshot = querySnapshot else { return }
                querySnapshot.documents.forEach { document in
                    do {
                        let user = try document.data(as: User.self)
                        users.append(user)
                    } catch {
                        print(error)
                    }
                }
                completion(.success(users))
            }
        }
    }

    func updateUserName(userId: String, name: String) {
        usersCollection.document(userId).setData(["name": name], merge: true)
    }

    func updateUserPhoto(userId: String, imageURL: String) {
        usersCollection.document(userId).setData(["imageURL": imageURL], merge: true)
    }

    func updateFCMToken(userId: String, fcmToken: String) {
        usersCollection.document(userId).setData(["fcmToken": fcmToken], merge: true)
    }

    func updateUserBlocklist(userId: String, blockId: String, hasBlocked: Bool) {
        let userRef = usersCollection.document(userId)
        if hasBlocked {
            userRef.updateData([
                "blockList": FieldValue.arrayRemove([blockId])
            ])
        } else {
            userRef.updateData([
                "blockList": FieldValue.arrayUnion([blockId])
            ])
        }
    }

    func updateUserRecipePost(recipeId: String, userId: String, isNewPost: Bool) {
        let userRef = usersCollection.document(userId)
        if isNewPost {
            userRef.updateData([
                Constant.recipesId: FieldValue.arrayUnion([recipeId])
            ])
        } else {
            userRef.updateData([
                Constant.recipesId: FieldValue.arrayRemove([recipeId])
            ])
        }
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
                if Auth.auth().currentUser == nil {
                    querySnapshot.documents.forEach { document in
                        do {
                            let share = try document.data(as: Share.self)
                            let bbfTimeInterval = Double(share.bestBefore.seconds)
                            let shareDayComponent = Calendar.current.component(.day, from: Date(timeIntervalSince1970: bbfTimeInterval))
                            let today = Calendar.current.component(.day, from: Date())
                            if bbfTimeInterval < Date().timeIntervalSince1970 && shareDayComponent != today {
                                self.deleteSharePost(shareId: share.shareId)
                                self.updateUserSharePost(shareId: share.shareId, userId: share.authorId, isNewPost: false)
                            } else {
                                shares.append(share)
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }
                    completion(.success(shares))
                } else {
                    self.fetchUserData(userId: Constant.getUserId()) { result in
                        switch result {
                        case .success(let user):
                            querySnapshot.documents.forEach { document in
                                do {
                                    let share = try document.data(as: Share.self)
                                    let bbfTimeInterval = Double(share.bestBefore.seconds)
                                    let shareDayComponent = Calendar.current.component(.day, from: Date(timeIntervalSince1970: bbfTimeInterval))
                                    let today = Calendar.current.component(.day, from: Date())
                                    if bbfTimeInterval < Date().timeIntervalSince1970 && shareDayComponent != today {
                                        self.deleteSharePost(shareId: share.shareId)
                                        self.updateUserSharePost(shareId: share.shareId, userId: share.authorId, isNewPost: false)
                                    } else if !user.blockList.contains(share.authorId) {
                                        shares.append(share)
                                    }
                                } catch {
                                    completion(.failure(error))
                                }
                            }
                            completion(.success(shares))
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
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

    func updateShareReports(shareId: String, userId: String) {
        let recipeRef = sharesCollection.document(shareId)
        recipeRef.updateData([
            "reports": FieldValue.arrayUnion([userId])
        ])
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
            var conversation: Conversation?
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
