//
//  Habit.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import Foundation

let INDEX_TO_DAY = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

typealias Minutes = Int

enum DayOfWeek: Int, Codable {
    case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

struct Habit: Codable, Identifiable, CustomStringConvertible {
    
    var description: String {
        return "Habit: \(self.type)"
    }
    
    let id: UUID
    
    let type: String
    
    let minutes: Minutes
    
    let dayOfWeek: DayOfWeek
    
    let dayInterval: DayInterval
    
}
