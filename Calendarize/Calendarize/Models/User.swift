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
    
    init(email: String, fullname: String) {
        self.email = email
        self.fullName = fullname
        
        // Defaults
        self.habits = [:]
        self.priorityTasks = []
        self.regularTasks = []
        self.savedHabitTags = ["Gym", "Read", "Prayer", "Run", "Stretch", "Relax", "Family"]
        self.awakeInterval  = DayInterval(startTime: Time(fromString: "8:00 AM"), endTime: Time(fromString: "10:00 PM"))
    }
    
    // When User is stored, it's UID property is used as key.
    @DocumentID var uid: UserID?
    
    var email: String
    
    var fullName: String
    
    var habits: Dictionary<String, [Habit]>
    
    var priorityTasks: [Task]
    
    var regularTasks: [Task]
    
    var savedHabitTags: [String]
    
    var awakeInterval: DayInterval
    
    // MARK: Defaults to nil, update when calendar generated
    var busynessIndex: Int?
}
