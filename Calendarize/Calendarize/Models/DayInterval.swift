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
    
}


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
