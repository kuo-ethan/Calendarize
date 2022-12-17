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
    
    func addUser(_ uid: UserID, _ user: User, _ completion: ((Error?) -> Void)?) {
        do {
            try db.collection("users").document(uid).setData(from: user, completion: completion)
        }
        catch { }
    }
    
    func updateUser(_ user: User, _ completion: ((Error?) -> Void)?) {
        guard let uid = user.uid else { return }
        do {
            print("Setting data")
            try db.collection("users").document(uid).setData(from: user, completion: completion)
        }
        catch {
            print("ERROR: Failed to set data")
        }
    }
}
