//
//  Utility.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

/* A class with a bunch of random utility methods. */
import Foundation

class Utility {
    
    // Note that string does not show 0 hours.
    static func durationInSecondsToStringifiedHoursAndMinutes(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((Int(duration) % 3600) / 60)
        if hours == 0 {
            return "\(minutes)m"
        } else if minutes == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(minutes)m"
    }
    
    static func timeTicksToStringInHours(_ timeTicks: Int) -> String {
        return String(Double(timeTicks) / 2.0)
    }
    
    static func stringInHoursToTimeTicks(_ timeInHours: String) -> Int {
        return Int(Double(timeInHours)! * 2)
    }
    
    static func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd h:mm a"
        return dateFormatter.string(from: date)
    }
    
}