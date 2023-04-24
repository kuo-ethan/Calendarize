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
// NOTE: Midnight is 24:00 not 00:00
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
        // timeString is in the form of "10:35 PM"
        if timeString == "12:00 AM" {
            print("midnight!")
            hour = 24
            minutes = 0
            return
        }
        var temp = timeString.components(separatedBy: ":")
        var hr = Int(temp[0])!
        temp = temp[1].components(separatedBy: " ")
        minutes = Int(temp[0])!
        if hr == 12 {
            hr = 0
        }
        if temp[1] == "PM" {
            hour = hr + 12
        } else {
            hour = hr
        }
    }
    
    init(hour: Int, minutes: Int) {
        self.hour = hour
        self.minutes = minutes
    }
    
    func toString() -> String {
        if hour == 24 && minutes == 0 {
            return "12:00 AM"
        }
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
