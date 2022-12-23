//
//  Algorithms.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/23/22.
//

import Foundation

// MARK: The main algorithm.
func calendarize1(W: [Work], H: [Habit], T: [Task]) -> [CKEvent] {
    
    var ckEvents: [CKEvent] = []
    
    // MARK: Preprocesing
    // Add priority tasks as habits
    // Sort W by start + end, H by start, T by deadline
    // Iterate and shift, store shifted values in dictionary?
    
    // MARK: DP Algorithm
    
    // MARK: Postprocessing
    
    return ckEvents
}

// Given some tasks, returns the completion order that maximizes # deadlines met.
private func taskSchedulingWithDurations(forTasks T: [Task]) {
    // Top down DP with memoization better
    
}
