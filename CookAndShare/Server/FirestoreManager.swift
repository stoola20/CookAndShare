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

enum FirestoreError: Error, LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noDocument:
            return "No document exists."
        }
    }

    case noDocument
}

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

class FirestoreManager {
    static let shared = FirestoreManager()
    let recipesCollection = Firestore.firestore().collection(Constant.firestoreRecipes)
    let usersCollection = Firestore.firestore().collection(Constant.firestoreUsers)
    let sharesCollection = Firestore.firestore().collection(Constant.firestoreShares)
    let conversationsCollection = Firestore.firestore().collection(Constant.firestoreConversations)
    let storage = Storage.storage()

// MARK: - Private
    private func parseDucument<T: Codable>(snapshot: DocumentSnapshot?, error: Error?) -> Result<T?, Error> {
        if let error = error {
            let errorMessage = error.localizedDescription
            print("DEBUG: Nil document", errorMessage)
            return .failure(error)
        } else {
            guard let snapshot = snapshot, snapshot.exists else { return .failure(FirestoreError.noDocument)}
            var model: T?
            do {
                model = try snapshot.data(as: T.self)
            } catch {
                print("DEBUG: Error: decoding\(T.self) data -", error.localizedDescription)
            }
            return .success(model)
        }
    }

    private func parseDocuments<T: Codable>(snapshot: QuerySnapshot?, error: Error?) -> Result<[T], Error> {
        if let error = error {
            let errorMessage = error.localizedDescription
            print("DEBUG: Error feat hing snapshot -", errorMessage)
            return .failure(error)
        } else {
            guard let snapshot = snapshot else { return .failure(FirestoreError.noDocument) }

            var models: [T] = []
            snapshot.documents.forEach { document in
                do {
                    let item = try document.data(as: T.self)
                    models.append(item)
                } catch {
                    print("DEBUG: Error decoding \(T.self) data -", error.localizedDescription)
                }
            }
            return .success(models)
        }
    }

// MARK: - Methods
    func getDocument<T: Codable>(_ docRef: DocumentReference, completion: @escaping (Result<T?, Error>) -> Void) {
        docRef.getDocument { snapshot, error in
            completion(self.parseDucument(snapshot: snapshot, error: error))
        }
    }

    func getDocuments<T: Codable>(_ query: Query, completion: @escaping (Result<[T], Error>) -> Void) {
        query.getDocuments { snapshot, error in
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }

    func listenDocument<T: Codable>(_ docRef: DocumentReference, completion: @escaping (Result<T?, Error>) -> Void) {
        docRef.addSnapshotListener { snapshot, error in
            completion(self.parseDucument(snapshot: snapshot, error: error))
        }
    }

    func listenDocuments<T: Codable>(_ query: Query, completion: @escaping (Result<[T], Error>) -> Void) {
        query.addSnapshotListener { snapshot, error in
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }

    func setData<T: Codable>(_ data: T, to docRef: DocumentReference) {
        do {
            try docRef.setData(from: data)
            print("Document added with ID: \(docRef.documentID)")
        } catch let error {
            print("Error adding document: \(error)")
        }
    }

    func arrayUnionString(docRef: DocumentReference, field: String, value: String) {
        docRef.updateData([
            field: FieldValue.arrayUnion([value])
        ])
    }

    func arrayRemoveString(docRef: DocumentReference, field: String, value: String) {
        docRef.updateData([
            field: FieldValue.arrayRemove([value])
        ])
    }

    func arrayUnionDict(docRef: DocumentReference, field: String, value: [String: Any]) {
        docRef.updateData([
            field: FieldValue.arrayUnion([value])
        ])
    }

    func deleteDocument(docRef: DocumentReference) {
        docRef.delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
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

// MARK: - User
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

    func updateUserData(userId: String, field: String, value: String) {
        FirestoreEndpoint.users.collectionRef.document(userId).setData([field: value], merge: true)
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

    func updateConversation(channelId: String, message: [String: Any]) {
        let conversationRef = conversationsCollection.document(channelId)
        conversationRef.updateData([
            "messages": FieldValue.arrayUnion([message])
        ])
    }
}
