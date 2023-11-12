//
//  Task.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import Foundation

typealias TimeTicks = Int // 30 minute time unit

enum TaskType: String, Codable {
    case priority
    case current
    case noncurrent
}

class Task: CalendarizeEvent, Codable, Identifiable, CustomStringConvertible {
    
    var description: String { "Task: \(self.name)" } // For debugging
    
    
    init(name: String, timeTicks: TimeTicks, deadline: Date) {
        self.name = name
        self.timeTicks = timeTicks
        self.deadline = deadline
        self.type = .current
    }
    
    var name: String
    
    var timeTicks: TimeTicks
    
    var deadline: Date
    
    var type: TaskType
    
    func toString() -> String {
        return "\(name) takes \(timeTicks) timeticks"
    }
    
}
