//
//  MinuteItem.swift
//  Calendarize
//
//  Created by Ethan Kuo on 11/12/23.
//

import Foundation

/// Smallest unit of the schedule. Contains a pointer to any scheduled tasks or habits
class MinuteItem: CustomStringConvertible {
    let title: String
    let pointer: CalendarizeEvent?
    
    var description: String {
        if let pointer {
            return "\(title) \(String(describing: pointer))"
        } else {
            return title
        }
    }
    
    init(title: String, pointer: CalendarizeEvent?) {
        self.title = title
        self.pointer = pointer
    }

}

let AVAILABLE = MinuteItem(title: "available", pointer: nil)
let ASLEEP = MinuteItem(title: "asleep", pointer: nil)
let UNAVAILABLE = MinuteItem(title: "unavailable", pointer: nil)
