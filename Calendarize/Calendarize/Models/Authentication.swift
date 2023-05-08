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
        
        // calls that closure when that document is updated
        userListener = Database.shared.db.collection("users").document(uid).addSnapshotListener { [weak self] docSnapshot, error in
            print("snapshot listener triggered")
            guard let document = docSnapshot else {
                fatalError("ERROR: document with UID \(uid) not found")
            }
            guard let user = try? document.data(as: User.self) else {
                fatalError("ERROR: user from firestore not decodable")
            }
            self?.currentUser = user
            if let completion = completion { // MARK: ayo? i think this should be outside...
                completion()
            }
        }
    }
    
    /* Create a new document for a new user, then link the user as above */
    func linkNewUser(withuid uid: String, withData user: User, completion: (() -> Void)?) {
        Database.shared.addUser(uid, user) { error in
            if let _ = error {
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
