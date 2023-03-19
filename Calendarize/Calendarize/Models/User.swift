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
        self.ckEvents = []
        self.awakeInterval  = DayInterval(startTime: Time(fromString: "8:00 AM"), endTime: Time(fromString: "10:00 PM"))
        self.productivityStyle = .Dynamic
        self.breakRange = [2, 6]
    }
    
    @DocumentID var uid: UserID?
    
    var email: String
    
    var fullName: String
    
    // var habits: [Habit]
    var habits: Dictionary<String, [Habit]>
    
    var priorityTasks: [Task]
    
    var regularTasks: [Task]
    
    var savedHabitTags: [String]
    
    // MARK: CalendarKit events for the next two full days
    var ckEvents: [CKEvent]
    
    var awakeInterval: DayInterval
    
    var productivityStyle: ProductivityStyle
    
    var breakRange: [Int]
    
    // MARK: Defaults to nil, update when calendar generated
    var busynessIndex: Int?
}

enum ProductivityStyle: String, Codable {
    case Dynamic, Frontload, Balanced, Backload
}
