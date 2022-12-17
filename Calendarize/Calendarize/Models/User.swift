//
//  User.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import Foundation
import FirebaseFirestoreSwift

typealias UserID = String

class User: Codable {
    
    init(email: String, fullname: String, habits: [Habit], tasks: [Task]) {
        self.email = email
        self.fullname = fullname
        self.habits = habits
        self.tasks = tasks
    }
    
    @DocumentID var uid: UserID?
    
    var email: String
    
    var fullname: String
    
    var habits: [Habit]
    
    var tasks: [Task]
    
    var savedHabitTags: [String] = ["Gym", "Read", "Prayer", "Run", "Stretch", "Relax", "Family"]
    
    // MARK: CalendarKit events for the next two full days
    var ckEvents: [CKEvent] = []
}

