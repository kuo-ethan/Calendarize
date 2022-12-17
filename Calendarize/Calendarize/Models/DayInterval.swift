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


struct Time: Codable {
    
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
}
