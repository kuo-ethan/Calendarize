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
import NotificationBannerSwift

/// The home page of the app. Displays local calendar view.
final class HomeVC: DayViewController {
    
    private var eventStore = EKEventStore()
    
    static var shared: HomeVC! // Singleton object is maintained
    
    private var bannerQueue = NotificationBannerQueue(maxBannersOnScreenSimultaneously: 3)
    
    var schedule: [MinuteItem]! // In-memory representation of the schedule (an array indexed by the minute).
    
    var dropped: [CalendarizeEvent]! // Events that were dropped in the current schedule
    
    var startDate: Date!
    
    var endDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: #selector(didTapProfile))
        navigationItem.rightBarButtonItem = profileButton
        let refreshButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(didTapRefresh))
        navigationItem.leftBarButtonItem = refreshButton
        
        // The app must have access to the user's calendar. The app will remain unresponsive until access granted.
        requestAccessToCalendar()
        
        // Subscribe to notifications to reload the calendar UI whenever event store changes
        //subscribeToNotifications()
        
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
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                if granted {
                    self?.handleCalendarAccessGranted()
                } else {
                    self?.handleCalendarAccessDenied(error)
                }
            }
        } else {
            // Fallback on earlier versions
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                if granted {
                    self?.handleCalendarAccessGranted()
                } else {
                    self?.handleCalendarAccessDenied(error)
                }
            }
        }

    }
    
    private func handleCalendarAccessGranted() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.initializeStore()
            self.subscribeToNotifications()
            self.reloadData()
        }
    }
    
    private func handleCalendarAccessDenied(_ error: Error?) {
        print(error?.localizedDescription ?? "Calendar access denied") // For debugging
        // Show an alert to the user explaining why the access is needed
        let alert = UIAlertController(title: "Calendar Access Required",
                                      message: "This app requires permission to read and write to your Apple Calendar. Please enable Full Access in the Settings app.",
                                      preferredStyle: .alert)

        // Add an action that opens the app settings
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingsUrl) else {
                return
            }

            UIApplication.shared.open(settingsUrl)
        })

        // Add a cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            guard let self = self, let window = self.view.window else { return }
            let overlayView = self.createGrayOverlayView()
            window.addSubview(overlayView)
        })

        // Present the alert
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    private func createGrayOverlayView() -> UIView {
        let overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent
        overlayView.isUserInteractionEnabled = true // To block touch events
        return overlayView
    }
    
    private func subscribeToNotifications() {
        print("subscribed to notifications")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeChanged(_:)),
                                               name: .EKEventStoreChanged,
                                               object: eventStore)
    }
    
    private func initializeStore() {
        eventStore = EKEventStore()
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        reloadData()
    }
    
    // MARK: DayViewDataSource
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        // The `date` always has it's Time components set to 00:00:00 of the day requested
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        
        // Get the day's events across all calendars (including "Calendarize" if exists)
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let eventKitEvents = eventStore.events(matching: predicate)
        let calendarKitEvents = eventKitEvents.map(EKWrapper.init)
        
        return calendarKitEvents
    
    }
    
    // MARK: DayViewDelegate
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let event = eventView.descriptor as? EKWrapper else {
            return
        }
        presentDetailViewForEvent(event.ekEvent)
    }
    
    private func presentDetailViewForEvent(_ ekEvent: EKEvent) {
        let eventController = EKEventViewController()
        eventController.event = ekEvent
        eventController.delegate = self
        eventController.allowsCalendarPreview = true
        eventController.allowsEditing = true
        navigationController?.pushViewController(eventController, animated: true)
    }
    
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        // Cancel editing current event and start creating a new one
        endEventEditing()
        let newEKWrapper = createNewEvent(at: date)
        create(event: newEKWrapper, animated: true)
    }
    
    private func createNewEvent(at date: Date) -> EKWrapper {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents // TODO: Handle nil default calendar
        
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
    
    
    @objc private func didTapProfile() {
        navigationController?.pushViewController(ProfileVC(), animated: true)
    }
    
    @objc private func didTapRefresh() {
        let currentUser = Authentication.shared.currentUser!
        calendarize(for: currentUser) // Generate schedule
        displayScheduleAndAlerts()
        updateWorkloadIndex()
        reloadData()
    }
    
    // MARK: Algorithm
    /// Generate random schedule from current time to end of tomorrow that maximizes deadlines met under habit constraints.
    private func calendarize(for user: User) {
        
        // Useful constants and setup
        startDate = roundToNextFiveMinutes(Date())
        dropped = []
        let calendar = Calendar.current
        let todaysDay = DayOfWeek(rawValue: calendar.dateComponents([.weekday], from: startDate).weekday! - 1)
        let tomorrowsDay = DayOfWeek(rawValue: calendar.dateComponents([.weekday], from: startDate).weekday!)
        var TWO_DAY_COMPONENTS = DateComponents()
        TWO_DAY_COMPONENTS.day = 2
        var ONE_DAY_COMPONENTS = DateComponents()
        ONE_DAY_COMPONENTS.day = 1
        var ONE_MIN_COMPONENTS = DateComponents()
        ONE_MIN_COMPONENTS.minute = 1
        endDate = calendar.startOfDay(for: calendar.date(byAdding: TWO_DAY_COMPONENTS, to: startDate)!)
        let events = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil))
    
        schedule = Array(repeating: AVAILABLE, count: minutes(from: startDate, to: endDate))
        
        
        // MARK: Sleep
        let bedTime = user.awakeInterval.endTime
        let wakeUpTime = user.awakeInterval.startTime
        
        // TODO: Currently we assume bed time falls within today, and wake up time falls within tomorrow.
        let bedTimeDate = calendar.date(bySettingHour: bedTime.hour, minute: bedTime.minutes, second: 0, of: startDate)!
        let wakeUpDate = calendar.date(bySettingHour: wakeUpTime.hour, minute: wakeUpTime.minutes, second: 0, of: calendar.date(byAdding: ONE_DAY_COMPONENTS, to: startDate)!)!
        
        // Sleep from tonight to tomorrow morning
        let bedTimeIndex = index(for: bedTimeDate)
        let wakeUpIndex = index(for: wakeUpDate)
        for i in bedTimeIndex..<wakeUpIndex {
            schedule[i] = ASLEEP
        }
        
        // Sleep from earlier today
        for i in 0..<max(0, (wakeUpIndex - (24 * 60))) {
            schedule[i] = ASLEEP
        }
        
        // Sleep from later tomorrow
        for i in (bedTimeIndex + (24 * 60))..<schedule.count {
            schedule[i] = ASLEEP
        }
        
        
        // MARK: Events
        for event in events {
            if event.isAllDay {
                // Ignore all day events like holidays
                continue
            }
            let startIndex = index(for: event.startDate)
            let endIndex = index(for: event.endDate)
            for i in startIndex..<endIndex {
                schedule[i] = UNAVAILABLE
            }
        }
        
        // MARK: Habits
        var startIndices: Dictionary<Int, CalendarizeEvent> = [:] // Used in randomization algorithm
        var deterministicSchedule: [MinuteItem] = schedule // An optimal schedule without randomization
        for type in user.habits.keys {
            for habit in user.habits[type]! {
                // Assert habits inside today or tomorrow and store start of that day
                var referenceDateStart: Date!
                if habit.dayOfWeek == todaysDay {
                    referenceDateStart = calendar.startOfDay(for: startDate)
                } else if habit.dayOfWeek == tomorrowsDay {
                    referenceDateStart = calendar.startOfDay(for: calendar.date(byAdding: ONE_DAY_COMPONENTS, to: startDate)!)
                } else {
                    continue
                }
                
                // Get truncated indices for the start and end of habit. End date is an EXCLUSIVE upper bound.
                let startTime = habit.dayInterval.startTime
                let endTime = habit.dayInterval.endTime
                let habitStartDate = calendar.date(byAdding: .minute, value: startTime.hour * 60 + startTime.minutes, to: referenceDateStart)!
                let habitEndDate = calendar.date(byAdding: .minute, value: endTime.hour * 60 + endTime.minutes, to: referenceDateStart)!
                let startIndex = index(for: habitStartDate)
                let endIndex = index(for: habitEndDate)
                
                // Habit window of opportunity has already passed
                if endIndex == 0 { continue }
                
                // Attempt to backload
                var i = endIndex - 1
                var streak = 0
                var habitScheduled = false
                while !habitScheduled && i >= startIndex {
                    if deterministicSchedule[i] === AVAILABLE { streak += 1 } 
                    else { streak = 0 }
                    if streak == habit.minutes {
                        habitScheduled = true
                        startIndices[i] = habit
                        let habitItem = MinuteItem(title: "habit", pointer: habit)
                        for j in 0..<streak {
                            deterministicSchedule[i + j] = habitItem
                        }
                    }
                    i -= 1
                }
                if !habitScheduled {
                    // This habit is impossible to complete
                    dropped.append(habit)
                }
            }
        }
        
        // MARK: Tasks
        /// Deterministically schedules tasks such that the maximum number of deadlines are met
        /// Note that task deadlines are an exclusive upper bound.
        func taskSchedulingWithDurations(for tasks: [Task]) {
            let sortedTasks = tasks.sorted { a, b in
                return a.deadline.compare(b.deadline) == .orderedAscending
            }
            
            let N = sortedTasks.count
            if N == 0 {
                return
            }
            let d_N = minutes(from: startDate, to: sortedTasks.last!.deadline)
            
            // Memoization cache
            struct Pair: Hashable {
                let i: Int
                let j: Int
            }
            var cache: Dictionary<Pair, [(Int, Int)]> = [:]
            
            /// A top-down dynamic programming algorithm. Finds optimal scheduling of the first 'i' tasks in the first 'j' minutes.
            /// - Returns: a list containing the task index and the starting index they are to be scheduled at
            func subproblem(i: Int, j: Int) -> [(Int, Int)] {
                // Base case
                if i == 0 {
                    return []
                }
                
                // Without the last task
                if cache[Pair(i: i-1, j: j)] == nil {
                    cache[Pair(i: i-1, j: j)] = subproblem(i: i-1, j: j)
                }
                let without_last_task = cache[Pair(i: i-1, j: j)]!
                
                // With the last task
                let last_task = sortedTasks[i-1]
                var with_last_task: [(Int, Int)] = []
                var minutesLeft = last_task.timeTicks * 30
                
                // Compute how many minutes it takes to backload the last task
                var index = min(j, minutes(from: startDate, to: last_task.deadline)) - 1
                
                // Fast foward to first available index
                while index > 0 && deterministicSchedule[index] !== AVAILABLE {
                    index -= 1
                }
                
                while index >= 0 {
                    if deterministicSchedule[index] === AVAILABLE {
                        minutesLeft -= 1
                    }
                    if minutesLeft == 0 {
                        // Schedule the last task from index
                        if cache[Pair(i: i-1, j: index)] == nil {
                            cache[Pair(i: i-1, j: index)] = subproblem(i: i-1, j: index)
                        }
                        with_last_task = cache[Pair(i: i-1, j: index)]! + [(i-1, index)]
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
                    // If tie, then take the schedule without last task, since it is least urgent.
                    cache[Pair(i: i, j: j)] = without_last_task
                }
                return cache[Pair(i: i, j: j)]!
            }
            
            // Run the task scheduling algorithm
            let res = subproblem(i: N, j: d_N)
            
            var optimalTaskIndices: [Int] = []
            for i in 0..<res.count {
                optimalTaskIndices.append(res[i].0)
            }
            
            // Alert user of which tasks were dropped
            for i in 0..<N {
                if !optimalTaskIndices.contains(i) && !(sortedTasks[i].type == .noncurrent) {
                    dropped.append(sortedTasks[i])
                }
            }
            
            // Write each task into the deterministic schedule.
            for (taskIndex, scheduleIndex) in res {
                let currTask = sortedTasks[taskIndex]
                startIndices[scheduleIndex] = currTask
                
                var i = scheduleIndex
                var currMinutes = (currTask.timeTicks * 30)
                let currTaskItem = MinuteItem(title: "task", pointer: currTask)
                while currMinutes > 0 {
                    if deterministicSchedule[i] === AVAILABLE {
                        deterministicSchedule[i] = currTaskItem
                        currMinutes -= 1
                    }
                    i += 1
                }
            }
        }
        
        // MARK: (a) Priority Tasks
        let priorityTasks = user.priorityTasks.filter { task in
            return startDate.compare(task.deadline) == .orderedAscending
        }
        taskSchedulingWithDurations(for: priorityTasks)
        
        // MARK: (b) Current Tasks
        // Current tasks have startDate < deadline <= endDate.
        let currentTasks = user.regularTasks.filter { task in
            startDate < task.deadline && task.deadline <= endDate
        }
        taskSchedulingWithDurations(for: currentTasks)
        
        // MARK: (c) Non-current Tasks
        // A non-current task has a deadline after our current window. Compute how many hours per day it takes to complete that task, and if >= 1 hr, then try to schedule that many hours.
        let noncurrentTasks = user.regularTasks.filter { task in
            return endDate < task.deadline
        }
        
        var dummyTasks: [Task] = []
        for noncurrentTask in noncurrentTasks {
            let differenceInDays = Int(ceil(noncurrentTask.deadline.timeIntervalSince(startDate) / 3600 / 24))
            
            let avgTimeTicksPerDay = noncurrentTask.timeTicks / differenceInDays
            let dummyTask = Task(name: noncurrentTask.name, timeTicks: avgTimeTicksPerDay, deadline: endDate)
            dummyTask.type = .noncurrent
            dummyTasks.append(dummyTask)
        }
        taskSchedulingWithDurations(for: dummyTasks)
        
        
        // MARK: Randomization
        let sortedInitialIndices = startIndices.keys.sorted()
            
        /*
         Randomly schedule the event somewhere before or at INDEX. The new index will be uniformly chosen at random from all indices with minimum fragmentation. Only indicies that are a multiple of 5 minutes will be considered as possible indices.
         */
        /// Randomize a deterministic optimal schedule by iterating through each event sequentially and moving them randomly to an earlier time.
        /// This function takes a specific event and finds all start indices that minimize fragmentation of the event. Then, it randomly selects an index and schedules the task.
        /// The motivation for minimal fragmentation is that a task is best completed with minimal interruptions.
        func randomlySchedule(event: CalendarizeEvent, before index: Int) {
            
            /// Counts the number of fragments created when scheduling some minutes starting at index. 
            /// Assumes schedule[i] === AVAILABLE and that the minutes are schedulable.
            func countFragments(at index: Int, forMinutes minutes: Int) -> Int {
                var fragments = 1
                var i = index+1
                var m = minutes-1
                
                while m > 0 {
                    if schedule[i] === AVAILABLE {
                        if schedule[i-1] !== AVAILABLE {
                            // Found start of new fragment
                            fragments += 1
                        }
                        m -= 1
                    }
                    i += 1
                }
                return fragments
            }
            
            // Set up
            var validIndices: [Int] = [index]
            var duration: Int // How many minutes need to be scheduled from that index
            var item: MinuteItem!
            
            if let habit = event as? Habit {
                // A valid habit scheduling has exactly one fragment.
                item = MinuteItem(title: habit.name, pointer: habit)
                duration = habit.minutes
                let earliestTime = habit.dayInterval.startTime
                let earliestDate = roundToNextFiveMinutes(calendar.date(bySettingHour: earliestTime.hour, minute: earliestTime.minutes, second: 0, of: startDate)!)
                // var earliestIndex = minutes(from: startDate, to: earliestDate)
                var earliestIndex = self.index(for: earliestDate)
                if habit.dayOfWeek == tomorrowsDay {
                    earliestIndex += (24 * 60)
                }
                
                var i = earliestIndex
                while i < index {
                    if schedule[i] === AVAILABLE && countFragments(at: i, forMinutes: habit.minutes) == 1 {
                        validIndices.append(i)
                    }
                    i += 5
                }
            } else if let task = event as? Task {
                item = MinuteItem(title: task.name, pointer: task)
                duration = task.timeTicks * 30
                var minFragments = countFragments(at: index, forMinutes: duration)
                var i = 0
                while i < index {
                    if schedule[i] === AVAILABLE {
                        let currFragments = countFragments(at: i, forMinutes: duration)
                        if currFragments < minFragments {
                            // Found a new, less fragmented optimal
                            minFragments = currFragments
                            validIndices = [i]
                        } else if currFragments == minFragments {
                            validIndices.append(i)
                        }
                    }
                    i += 5
                }
            } else {
                fatalError("Attempting to schedule a non-event")
            }
            
            // Randomly pick an index and schedule from there
            var i = validIndices.randomElement()!
            var m = duration
            while m > 0 {
                if schedule[i] === AVAILABLE {
                    schedule[i] = item
                    m -= 1
                }
                i += 1
            }

        }
        
        // Randomly shift each event forward in sequential order
        for index in sortedInitialIndices {
            randomlySchedule(event: startIndices[index]!, before: index)
        }
    }
    
    /// Updates UI to show the generated schedule along with any alerts.
    private func displayScheduleAndAlerts() {
        
        // Prepare a fresh Calendarize calendar object.
        var calendarizeCalendar: EKCalendar!
        for cal in eventStore.calendars(for: .event) {
            if cal.title == "Calendarize" {
                calendarizeCalendar = cal
                break
            }
        }
        if calendarizeCalendar == nil {
            calendarizeCalendar = EKCalendar(for: .event, eventStore: eventStore)
            calendarizeCalendar.title = "Calendarize"
            calendarizeCalendar.cgColor = UIColor.primary.cgColor
            calendarizeCalendar.source = eventStore.defaultCalendarForNewEvents!.source // TODO: Handle nil default calendar
            try! eventStore.saveCalendar(calendarizeCalendar, commit: true)
        } else {
            let predicate = eventStore.predicateForEvents(withStart: calendar.date(byAdding: .year, value: -2, to: Date())!, end: calendar.date(byAdding: .year, value: 2, to: Date())!, calendars: [calendarizeCalendar])
            for ev in eventStore.events(matching: predicate) {
                try! eventStore.remove(ev, span: .thisEvent)
            }
        }
        
        // Update calendar UI with new schedule
        var last: CalendarizeEvent?
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
                        addCalendarizeEvent(for: last!, fromIndex: start!, toIndex: i-1, on: calendarizeCalendar)
                        last = curr
                        start = i
                    }

                } else {
                    // The end of a run
                    addCalendarizeEvent(for: last!, fromIndex: start!, toIndex: i-1, on: calendarizeCalendar)
                    last = nil
                    start = nil
                }
            }
        }
        if last != nil {
            addCalendarizeEvent(for: last!, fromIndex: start!, toIndex: schedule.count-1, on: calendarizeCalendar)
        }
        
//        // DEBUG: Print formatted schedule copy
//        var currDate: Date = startDate
//        for item in schedule {
//            print("\(currDate.formatted()): \(item.description)")
//            currDate = calendar.date(byAdding: ONE_MIN_COMPONENTS, to: currDate)!
//        }
        
        // Display alerts for dropped tasks and habits
        for droppedEvent in dropped {
            if let habit = droppedEvent as? Habit {
                let message = "Impossible to schedule \(habit.name) from \(habit.dayInterval.startTime.toString()) to \(habit.dayInterval.endTime.toString())"
                showErrorBanner(withTitle: "Habit dropped", subtitle: message)
            } else if let task = droppedEvent as? Task {
                let message = "Impossible to complete \(task.name) by its deadline"
                showErrorBanner(withTitle: "Task dropped", subtitle: message)
            }
        }
        if dropped.count == 0 {
            showErrorBanner(withTitle: "Success!", subtitle: "No habits or tasks were dropped")
        }
    }
    
    /// Creates EKEvent for a calendarize event given its start and end indices within the schedule array, inclusive.
    private func addCalendarizeEvent(for eventItem: CalendarizeEvent, fromIndex i: Int, toIndex j: Int, on ekCalendar: EKCalendar) {
        // Get fromDate and toDate
        var offsetComponents = DateComponents()
        offsetComponents.minute = i
        let fromDate = calendar.date(byAdding: offsetComponents, to: startDate)!
        offsetComponents.minute = j
        let toDate = calendar.date(byAdding: offsetComponents, to: startDate)!

        // Create the EKEvent
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = ekCalendar
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
    
    /// Updates work load index value given the current schedule.
    private func updateWorkloadIndex() {
        var freeCount = 0
        var awakeCount = 0
        for item in schedule {
            if item !== ASLEEP {
                awakeCount += 1
            }
            if item === AVAILABLE {
                freeCount += 1
            }
        }
        let temp = Double(freeCount) / Double(awakeCount)
        let workloadIndex = 100 - Int((temp * 100).rounded())
        
        let currentUser = Authentication.shared.currentUser!
        currentUser.busynessIndex = workloadIndex
        Database.shared.updateUser(currentUser, nil)
        return
    }
    
    

    private func roundToNextFiveMinutes(_ date: Date) -> Date {
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
    
    // Given any date, returns its corresponding index in the schedule
    private func index(for date: Date) -> Int {
        return min(max(0, minutes(from: startDate, to: date)), schedule.count)
    }
    
    
    // Copied from SignInVC
    private func showErrorBanner(withTitle title: String, subtitle: String? = nil) {
        showBanner(withStyle: .warning, title: title, subtitle: subtitle)
    }
    
    private func showBanner(withStyle style: BannerStyle, title: String, subtitle: String?) {
        // guard bannerQueue.numberOfBanners == 0 else { return }
        let banner = FloatingNotificationBanner(title: title, subtitle: subtitle,
                                                titleFont: .systemFont(ofSize: 17, weight: .medium),
                                                subtitleFont: .systemFont(ofSize: 14, weight: .regular),
                                                style: style)
        banner.backgroundColor = .primary
        banner.show(bannerPosition: .top,
                    queue: bannerQueue,
                    edgeInsets: UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15),
                    cornerRadius: 10,
                    shadowColor: .primaryText,
                    shadowOpacity: 0.3,
                    shadowBlurRadius: 10)
    }
}

// MARK: Extensions
extension HomeVC: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
}

extension HomeVC: EKEventViewDelegate {
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        navigationController?.popViewController(animated: true)
    }
    
    
}
