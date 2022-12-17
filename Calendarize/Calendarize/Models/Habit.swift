//
//  HabitType.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import Foundation

class Habit: Codable {
    
    init(type: String, instances: [HabitInstance]) {
        self.type = type
        self.instances = instances
    }
    
    var type: String
    
    var instances: [HabitInstance]
}
