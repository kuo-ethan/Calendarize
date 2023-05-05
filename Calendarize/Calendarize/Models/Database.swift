//
//  Database.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Database {
    
    static let shared = Database()
    
    let db = Firestore.firestore()
    
    /* Add mapping from UID to User object in the backend */
    func addUser(_ uid: UserID, _ user: User, _ completion: ((Error?) -> Void)?) {
        do {
            try db.collection("users").document(uid).setData(from: user, completion: completion)
        }
        catch {
            fatalError("ERROR: Failed to store new user in the backend")
        }
    }
    
    /* Update User object in firestore */
    func updateUser(_ user: User, _ completion: ((Error?) -> Void)?) {
        guard let uid = user.uid else { return }
        do {
            try db.collection("users").document(uid).setData(from: user, completion: completion)
        }
        catch {
            fatalError("ERROR: Failed to update user data")
        }
    }
}
