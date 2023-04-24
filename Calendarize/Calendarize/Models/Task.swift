//
//  Task.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import Foundation

typealias TimeTicks = Int

class Task: AddedEvent, Codable, Identifiable, CustomStringConvertible {
    var description: String {
        "Task: \(self.name)"
    }
    
    
    init(name: String, timeTicks: TimeTicks, deadline: Date) {
        self.name = name
        self.timeTicks = timeTicks
        self.deadline = deadline
        
        self.isPriority = false
    }
    
    var name: String
    
    // 1 time tick = 30 minutes
    var timeTicks: TimeTicks
    
    var deadline: Date
    
    var isPriority: Bool
    
    func toString() -> String {
        return "\(name) takes \(timeTicks) timeticks"
    }
    
}
