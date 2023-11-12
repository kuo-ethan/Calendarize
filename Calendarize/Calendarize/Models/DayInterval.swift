//
//  DayInterval.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import Foundation

struct DayInterval: Codable {
    
    let startTime: Time
    
    let endTime: Time
    
    var length: Int {
        return (endTime.hour * 60 + endTime.minutes) - (startTime.hour * 60 + startTime.minutes)
    }
    
}

// A (hours: minutes) time in 24 hour format
struct Time: Codable, Comparable, Equatable {
    static func < (lhs: Time, rhs: Time) -> Bool {
        return (lhs.hour * 60 + lhs.minutes) < (rhs.hour * 60 + rhs.minutes)
    }
    
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minutes == rhs.minutes
    }
    
    let hour: Int
    
    let minutes: Int
    
    init(fromString timeString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // "h" for hour, "mm" for minutes, "a" for AM/PM
        formatter.locale = Locale(identifier: "en_US_POSIX") // to ensure AM/PM is correctly interpreted

        let date = formatter.date(from: timeString)!
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)

        // Assign these values to your instance variables
        self.hour = hour
        self.minutes = minutes
    }
    
    init(hour: Int, minutes: Int) {
        self.hour = hour
        self.minutes = minutes
    }
    
    func toString() -> String {
        var postmark = "AM"
        var h = hour
        if h >= 12 {
            postmark = "PM"
            h -= 12
        }
        if h == 0 {
            h += 12
        }
        if minutes <= 9 {
            let m = "0" + String(minutes)
            return "\(h):\(m) \(postmark)"
        } else {
            let m = "" + String(minutes)
            return "\(h):\(m) \(postmark)"
        }
    }
    
    
}
