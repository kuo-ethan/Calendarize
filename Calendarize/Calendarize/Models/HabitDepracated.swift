//
//  HabitType.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import Foundation

class HabitDepracated: Codable {
    
    init(type: String, instances: [Habit]) {
        self.type = type
        self.instances = instances
    }
    
    var type: String
    
    var instances: [Habit]
}
