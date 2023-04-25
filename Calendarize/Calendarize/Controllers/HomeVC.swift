//
//  ViewController.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

final class HomeVC: DayViewController, EKEventEditViewDelegate {
    
    private var eventStore = EKEventStore()
    
    private var calendarizeCalendar: EKCalendar?
    
    static var shared: HomeVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: #selector(didTapProfile))
        navigationItem.rightBarButtonItem = profileButton
        let refreshButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(didTapRefresh))
        navigationItem.leftBarButtonItem = refreshButton
        
        // The app must have access to the user's calendar to show the events on the timeline
        requestAccessToCalendar()
        
        // Subscribe to notifications to reload the UI when
        subscribeToNotifications()
        
        // Consecutive calendar events should stack
        var calendarStyle = CalendarStyle()
        calendarStyle.timeline.eventGap = 2.0
        updateStyle(calendarStyle)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.view.backgroundColor = .white
    }
    
    private func requestAccessToCalendar() {
        // Request access to the events
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            // Handle the response to the request.
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.initializeStore()
                self.subscribeToNotifications()
                self.reloadData()
            }
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeChanged(_:)),
                                               name: .EKEventStoreChanged,
                                               object: eventStore)
    }
    
    private func initializeStore() {
        eventStore = EKEventStore()
        setCalendarizeCalendar()
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        reloadData()
    }
    
    // MARK: - DayViewDataSource
    
    // This is the `DayViewDataSource` method that the client app has to implement in order to display events with CalendarKit
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        // The `date` always has it's Time components set to 00:00:00 of the day requested
        print("DEBUG: Called eventsForDate(.)")
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        // By adding one full `day` to the `startDate`, we're getting to the 00:00:00 of the *next* day
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        
        // Get events from ALL calendars (including "Calendarize" if it exists!)
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        let eventKitEvents = eventStore.events(matching: predicate)
        
        let calendarKitEvents = eventKitEvents.map(EKWrapper.init)
        
//        if let currentUser = Authentication.shared.currentUser {
//            print("adding new events!")
//            let addedEvents = currentUser.ckEvents.map(CKWrapper.init)
//            return calendarKitEvents + addedEvents
//        } else {
//            return calendarKitEvents
//        }
        
        return calendarKitEvents
        
        
        
        
    }
    
    // MARK: - DayViewDelegate
    
    // MARK: Event Selection
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            return
        }
        presentDetailViewForEvent(ckEvent.ekEvent)
    }
    
    private func presentDetailViewForEvent(_ ekEvent: EKEvent) {
        let eventController = EKEventViewController()
        eventController.event = ekEvent
        eventController.allowsCalendarPreview = true
        eventController.allowsEditing = true
        navigationController?.pushViewController(eventController,
                                                 animated: true)
    }
    
    // MARK: Event Editing
    
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        // Cancel editing current event and start creating a new one
        endEventEditing()
        let newEKWrapper = createNewEvent(at: date)
        create(event: newEKWrapper, animated: true)
    }
    
    private func createNewEvent(at date: Date) -> EKWrapper {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        var components = DateComponents()
        components.hour = 1
        let endDate = calendar.date(byAdding: components, to: date)
        
        newEKEvent.startDate = date
        newEKEvent.endDate = endDate
        newEKEvent.title = "New event"

        let newEKWrapper = EKWrapper(eventKitEvent: newEKEvent)
        newEKWrapper.editedEvent = newEKWrapper
        return newEKWrapper
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? EKWrapper else {
            return
        }
        endEventEditing()
        beginEditing(event: descriptor,
                     animated: true)
    }
    
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else { return }
        if let originalEvent = event.editedEvent {
            editingEvent.commitEditing()
            
            if originalEvent === editingEvent {
                // If editing event is the same as the original one, it has just been created.
                // Showing editing view controller
                presentEditingViewForEvent(editingEvent.ekEvent)
            } else {
                // If editing event is different from the original,
                // then it's pointing to the event already in the `eventStore`
                // Let's save changes to oriignal event to the `eventStore`
                try! eventStore.save(editingEvent.ekEvent,
                                     span: .thisEvent)
            }
        }
        reloadData()
    }
    
    
    private func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = ekEvent
        eventEditViewController.eventStore = eventStore
        eventEditViewController.editViewDelegate = self
        present(eventEditViewController, animated: true, completion: nil)
    }
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }
    
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }
    
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapProfile() {
        navigationController?.pushViewController(ProfileVC(), animated: true)
    }
    
    /*
     User wants to generate a new schedule.
     */
    @objc private func didTapRefresh() {
        let currentUser = Authentication.shared.currentUser!
        calendarizeOPT(for: currentUser)
        reloadData()
    }
    
    /*
     Sets the 'Calendarize' calendar, if it exists.
     NOTE: we are assuming there's only one calendar with the name 'Calendarize'
     */
    private func setCalendarizeCalendar() {
        calendarizeCalendar = nil
        for calendar in eventStore.calendars(for: .event) {
            if calendar.title == "Calendarize" {
                print("DEBUG: There exists a calendar called Calendarize")
                calendarizeCalendar = calendar
            }
        }
    }
    
    // MARK: Algorithm
    /*
     Calendarize up to the end of tomorrow. Adds new EKEvents to the 'Calendarize' calendar.
     */
    private func calendarizeOPT(for user: User) {
        // Delete existing calendarize calendar, if exists
        setCalendarizeCalendar()
        if calendarizeCalendar != nil {
            try! eventStore.removeCalendar(calendarizeCalendar!, commit: true)
            print("DEBUG: Deleted Calendarize calendar.")
        }
        calendarizeCalendar = nil
        
        // Make a new empty calendar
        let freshCalendar = EKCalendar(for: .event, eventStore: eventStore)
        freshCalendar.title = "Calendarize"
        freshCalendar.cgColor = UIColor.primary.cgColor
        freshCalendar.source = eventStore.defaultCalendarForNewEvents!.source
        
        // Add it to the event store and save a pointer to it.
        try! eventStore.saveCalendar(freshCalendar, commit: true)
        calendarizeCalendar = freshCalendar
        
        // Useful constants and setup
        let startDate = roundUp(Date())
        var droppedAlerts: [String] = []
        let calendar = Calendar.current
        
        var TWO_DAY_COMPONENTS = DateComponents()
        TWO_DAY_COMPONENTS.day = 2
        var ONE_DAY_COMPONENTS = DateComponents()
        ONE_DAY_COMPONENTS.day = 1
        var ONE_MIN_COMPONENTS = DateComponents()
        ONE_MIN_COMPONENTS.minute = 1
        
        let endDate = calendar.startOfDay(for: calendar.date(byAdding: TWO_DAY_COMPONENTS, to: startDate)!)
        
        // Get any EK events that are from now to the end of tomorrow
        // Note: we must manually ignore events from Calendarize calendar
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        // Represents one minute in the calendar representation, and possibly contains a pointer to a Habit or Task.
        class MinuteItem: CustomStringConvertible {
            let title: String
            let pointer: AddedEvent?
            
            var description: String {
                if let pointer {
                    return "\(title) \(String(describing: pointer))"
                } else {
                    return title
                }
            }
            
            init(title: String, pointer: AddedEvent?) {
                self.title = title
                self.pointer = pointer
            }

        }
        
        let AVAILABLE = MinuteItem(title: "available", pointer: nil)
        let ASLEEP = MinuteItem(title: "asleep", pointer: nil)
        let UNAVAILABLE = MinuteItem(title: "unavailable", pointer: nil)
        
        // Create one big array that represents calendar
        var schedule: [MinuteItem] = Array(repeating: AVAILABLE, count: minutes(from: startDate, to: endDate))
        

        // MARK: Sleep
        // (Default sleep interval is 12AM to 8AM. Later, use Apple sleep data)
        var temp = calendar.date(byAdding: ONE_DAY_COMPONENTS, to: startDate)!
        temp = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: temp)!
        let bedTimeIndex = minutes(from: startDate, to: temp)
        temp = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: temp)!
        let wakeIndex = minutes(from: startDate, to: temp)
        for i in bedTimeIndex..<wakeIndex {
            schedule[i] = ASLEEP
        }
        
        // MARK: Event
        for event in events {
            if event.calendar == calendarizeCalendar {
                continue
            }
            let startIndex = max(0, minutes(from: startDate, to: event.startDate))
            let endIndex = min(schedule.count, minutes(from: startDate, to: event.endDate))
            for i in startIndex..<endIndex {
                schedule[i] = UNAVAILABLE
            }
        }
        
        // MARK: Habits
        // Sunday = 0, Monday = 1, ...
        let todaysDay = DayOfWeek(rawValue: calendar.dateComponents([.weekday], from: startDate).weekday! - 1)
        let tomorrowsDay = DayOfWeek(rawValue: calendar.dateComponents([.weekday], from: startDate).weekday!)
        for type in user.habits.keys {
            for habit in user.habits[type]! {
                // Create a reference date for the start of the habit's  date
                var referenceDateStart: Date!
                if habit.dayOfWeek == todaysDay {
                    referenceDateStart = calendar.startOfDay(for: startDate)
                } else if habit.dayOfWeek == tomorrowsDay {
                    referenceDateStart = calendar.startOfDay(for: calendar.date(byAdding: ONE_DAY_COMPONENTS, to: startDate)!)
                } else {
                    continue
                }
                
                // Get dates for the start and end of habit. Note that end date is an EXCLUSIVE upper bound.
                let startTime = habit.dayInterval.startTime
                let endTime = habit.dayInterval.endTime
                let habitStartDate = calendar.date(byAdding: .minute, value: startTime.hour * 60 + startTime.minutes, to: referenceDateStart)!
                let habitEndDate = calendar.date(byAdding: .minute, value: endTime.hour * 60 + endTime.minutes, to: referenceDateStart)!
                
                // Add the habit into the array
                let startIndex = max(0, minutes(from: startDate, to: habitStartDate))
                let endIndex = minutes(from: startDate, to: habitEndDate)
                
                // Check that this habit's interval hasn't already passed
                if 0 >= endIndex { continue }
                
                // Now attempt to schedule the habit continuously and as late as possible
                var i = endIndex - 1
                var streak = 0
                var habitScheduled = false
                while !habitScheduled && i >= startIndex {
                    if schedule[i] === AVAILABLE {
                        streak += 1
                    } else {
                        streak = 0
                    }
                    //print("\(i) - \(streak)")
                    if streak == habit.minutes {
                        // Found continuous period where habit can be completed
                        let habitItem = MinuteItem(title: "habit", pointer: habit)
                        for j in 0..<streak {
                            schedule[i + j] = habitItem
                        }
                        habitScheduled = true
                    }
                    i -= 1
                }
                if !habitScheduled {
                    // This habit was not scheudlable
                    droppedAlerts.append("\(habit.name) habit on \(INDEX_TO_DAY[habit.dayOfWeek.rawValue]) was dropped.")
                }
            }
        }
        
        // MARK: Tasks
        
        /*
         Given tasks, add the tasks to the schedule such that the maximum number of deadlines are met.
         */
        func taskSchedulingWithDurations(for tasks: [Task]) {
            let sortedTasks = tasks.sorted { a, b in
                return a.deadline.compare(b.deadline) == .orderedAscending // Edge case to consider: tasks with same deadline but different duration
            }
            
            let N = sortedTasks.count
            if N == 0 {
                return
            }
            let d_N = minutes(from: startDate, to: sortedTasks.last!.deadline)
            
            // Create a cache for memoization
            struct Pair: Hashable {
                let i: Int
                let j: Int
            }
            var cache: Dictionary<Pair, [Int]> = [:]
            
            /*
             Returns the indices of tasks for the optimal (maximum task completion) scheduling of the first i tasks into the first j minutes.
             This is top-down dynamic programming.
             */
            func subproblem(i: Int, j: Int) -> [Int] {
                // Base case
                if i == 0 {
                    return []
                }
                
                if cache[Pair(i: i-1, j: j)] == nil {
                    cache[Pair(i: i-1, j: j)] = subproblem(i: i-1, j: j)
                }
                let without_last_task = cache[Pair(i: i-1, j: j)]!

                var with_last_task: [Int] = []
                var minutesLeft = sortedTasks[i-1].timeTicks * 30
                
                // Compute how many minutes it takes to backload the last task
                var index = j-1
                while index >= 0 {
                    if schedule[index] === AVAILABLE {
                        minutesLeft -= 1
                    }
                    if minutesLeft == 0 {
                        // Possible to schedule the last task, starting from INDEX.
                        if cache[Pair(i: i-1, j: index)] == nil {
                            cache[Pair(i: i-1, j: index)] = subproblem(i: i-1, j: index)
                        }
                        with_last_task = cache[Pair(i: i-1, j: index)]! + [i-1]
                        break
                    }
                    index -= 1
                }
                
                // Return the choice that has more tasks completed
                if without_last_task.count > with_last_task.count {
                    cache[Pair(i: i, j: j)] = without_last_task
                } else if without_last_task.count < with_last_task.count{
                    cache[Pair(i: i, j: j)] = with_last_task
                } else {
                    // If either option has the same number of tasks, then take the more urgent one
                    cache[Pair(i: i, j: j)] = without_last_task
                }
                return cache[Pair(i: i, j: j)]!
            }
            
            // Now update the schedule
            let optimalTaskIndices = subproblem(i: N, j: d_N)
            
            // Alert user of which tasks were dropped
            for i in 0..<N {
                if !optimalTaskIndices.contains(i) {
                    droppedAlerts.append("Task \"\(sortedTasks[i].name)\" was dropped.")
                }
            }
            
            // Add tasks to schedule from the back (latest deadline frist)
            var i = d_N-1
            for taskIndex in optimalTaskIndices.reversed() {
                let currTask = sortedTasks[taskIndex]
                var currMinutes = (currTask.timeTicks * 30)
                let currTaskItem = MinuteItem(title: "task", pointer: currTask)
                while currMinutes > 0 {
                    if schedule[i] === AVAILABLE {
                        schedule[i] = currTaskItem
                        currMinutes -= 1
                    }
                    i -= 1
                }
            }
        }
        
        // MARK: (a) Priority Tasks
        // Filter out outdated priority tasks
        let priorityTasks = user.priorityTasks.filter { task in
            return startDate.compare(task.deadline) == .orderedAscending
        }
        taskSchedulingWithDurations(for: priorityTasks)
        
        // MARK: (b) Current Tasks
        // Current tasks have deadline between startDate and endDate.
        let currentTasks = user.regularTasks.filter { task in
            return startDate.compare(task.deadline) == .orderedAscending && (task.deadline.compare(endDate) == .orderedAscending || task.deadline.compare(endDate) == .orderedSame)
        }
        taskSchedulingWithDurations(for: currentTasks)
        
        // TODO: (c) Non-current Tasks
        
        // MARK: DEBUGGING: Print formatted schedule
        var currDate = startDate
        for item in schedule {
            print("\(currDate.formatted()): \(item.description)")
            currDate = calendar.date(byAdding: ONE_MIN_COMPONENTS, to: currDate)!
        }
        print(droppedAlerts)
        
        // MARK: Create EKEvents and add to 'Calendarize' calendar.
        
        /*
         Returns corresponding EKEvent for an AddedEvent given its start and end indices within the schedule array.
         */
        func addCalendarizeEvent(for eventItem: AddedEvent, fromIndex i: Int, toIndex j: Int) {
            print("DEBUG: Called addCalendarizeEvent(.)")
            // Get fromDate and toDate
            var offsetComponents = DateComponents()
            offsetComponents.minute = i
            let fromDate = calendar.date(byAdding: offsetComponents, to: startDate)!
            offsetComponents.minute = j
            let toDate = calendar.date(byAdding: offsetComponents, to: startDate)!

            // Create the EKEvent
            let newEKEvent = EKEvent(eventStore: eventStore)
            newEKEvent.calendar = calendarizeCalendar
            if let habit = eventItem as? Habit {
                newEKEvent.title = habit.name
                newEKEvent.startDate = fromDate
                newEKEvent.endDate = toDate
            } else {
                let task = eventItem as! Task
                newEKEvent.title = task.name
                newEKEvent.startDate = fromDate
                newEKEvent.endDate = toDate
            }
            do {
                try eventStore.save(newEKEvent, span: .thisEvent)
            } catch let error as NSError {
                print("failed to save event with error : \(error)")
            }
        }

        var last: AddedEvent?
        var start: Int?
        for i in 0..<schedule.count {
            if last == nil {
                // Not on a run yet
                if let curr = schedule[i].pointer {
                    // Starting a run
                    last = curr
                    start = i
                }
            } else {
                // Already on a run
                if let curr = schedule[i].pointer {
                    if curr !== last {
                        // The end of a run, and moving onto a new instance
                        addCalendarizeEvent(for: last!, fromIndex: start!, toIndex: i-1)
                        last = curr
                        start = i
                    }

                } else {
                    // The end of a run
                    addCalendarizeEvent(for: last!, fromIndex: start!, toIndex: i-1)
                    last = nil
                    start = nil
                }

            }
        }
        if last != nil {
            addCalendarizeEvent(for: last!, fromIndex: start!, toIndex: schedule.count-1)
        }
    }
    
    

    
    // Rounds date object to the next five munutes
    private func roundUp(_ date: Date) -> Date {
        let seconds: TimeInterval = ceil(date.timeIntervalSinceReferenceDate/300.0)*300.0
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
    
    // Rounds date object down to the next five munutes
    private func roundDown(_ date: Date) -> Date {
        let seconds: TimeInterval = floor(date.timeIntervalSinceReferenceDate/300.0)*300.0
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
    
    // Returns (in minutes) the time between two Dates
    private func minutes(from startDate: Date, to endDate: Date) -> Int {
        let diffSeconds = Int(endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970)
        return diffSeconds / 60
    }
    
    
}

