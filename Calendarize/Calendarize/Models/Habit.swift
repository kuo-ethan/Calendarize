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

class Habit: AddedEvent, Codable, Identifiable, CustomStringConvertible {
    
    var description: String {
        return "Habit: \(self.name)"
    }
    
    let id: UUID
    
    let name: String
    
    let minutes: Minutes
    
    let dayOfWeek: DayOfWeek
    
    let dayInterval: DayInterval
    
    init(id: UUID, type: String, minutes: Minutes, dayOfWeek: DayOfWeek, dayInterval: DayInterval) {
        self.id = id
        self.name = type
        self.minutes = minutes
        self.dayOfWeek = dayOfWeek
        self.dayInterval = dayInterval
    }
    
}
