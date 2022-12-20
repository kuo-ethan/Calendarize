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
        self.tasks = []
        self.savedHabitTags = ["Gym", "Read", "Prayer", "Run", "Stretch", "Relax", "Family"]
        self.ckEvents = []
        self.awakeInterval  = DayInterval(startTime: Time(fromString: "8:00 AM"), endTime: Time(fromString: "10:00 PM"))
        self.productivityStyle = .Dynamic
    }
    
    @DocumentID var uid: UserID?
    
    var email: String
    
    var fullName: String
    
    // var habits: [Habit]
    var habits: Dictionary<String, [Habit]>
    
    var tasks: [Task]
    
    var savedHabitTags: [String]
    
    // MARK: CalendarKit events for the next two full days
    var ckEvents: [CKEvent]
    
    var awakeInterval: DayInterval
    
    var productivityStyle: ProductivityStyle
}

enum ProductivityStyle: String, Codable {
    case Dynamic, Frontload, Balanced, Backload
}
