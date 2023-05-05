//
//  Authentication.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class Authentication {
    
    static let shared = Authentication()
    
    let auth = Auth.auth()
    
    var currentUser: User?
    
    private var userListener: ListenerRegistration?
    
    init() {
        guard let user = auth.currentUser else { return }
        linkUser(withuid: user.uid, completion: nil)
    }
    
    /* Given a UID, adds a listener to the user's document and updates currentUser */
    func linkUser(withuid uid: String, completion: (() -> Void)?) {
        
        // Whenever a user's document is updated in backend, we decode the user document and set it to currentUser. This is a valid feature because if a user has multiple devices and makes an update on one device, it should be immediately reflected in the other.
        // Note: The user document is decoded and set to currentUser upon app lauch automatically.
        userListener = Database.shared.db.collection("users").document(uid).addSnapshotListener { [weak self] docSnapshot, error in
            guard let document = docSnapshot else {
                fatalError("ERROR: Document with UID \(uid) not found")
            }
            guard let user = try? document.data(as: User.self) else {
                fatalError("ERROR: User from Firestore not decodable")
            }
            self?.currentUser = user
            if let completion = completion {
                completion()
            }
        }
    }
    
    /* Create a new document for a new user, then link the user as above */
    func linkNewUser(withuid uid: String, withData user: User, completion: (() -> Void)?) {
        Database.shared.addUser(uid, user) { error in
            if error != nil {
                fatalError("ERROR: failed to add a new user to Firestore")
            } else {
                self.linkUser(withuid: uid, completion: completion)
            }
        }
    }
    
    func unlinkCurrentUser() {
        userListener?.remove()
        currentUser = nil
    }
    
    func isSignedIn() -> Bool {
        return auth.currentUser != nil
    }
}
