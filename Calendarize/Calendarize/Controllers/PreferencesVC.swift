//
//  PreferencesVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/19/22.
//

import Foundation
import UIKit
// import SelectionList

class PreferencesVC: UIViewController {
    
//    let productivityStyleLabel: TitleLabel = {
//        let label = TitleLabel(withText: "Productivity Style:", ofSize: DEFAULT_FONT_SIZE)
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        return label
//    }()
//
//    let productivityStyleList: SelectionList = {
//        let selectionList = SelectionList()
//        selectionList.items = ["Dynamic", "Frontload", "Balanced", "Backload"]
//        selectionList.allowsMultipleSelection = false
//        selectionList.isSelectionMarkTrailing = false
//        selectionList.selectionImage = UIImage(systemName: "circle.fill")
//        selectionList.deselectionImage = UIImage(systemName: "circle")
//        selectionList.translatesAutoresizingMaskIntoConstraints = false
//
//        let currentProductivityStyle = Authentication.shared.currentUser!.productivityStyle
//        switch (currentProductivityStyle) {
//            case .Dynamic:
//                selectionList.selectedIndex = 0
//            case .Frontload:
//                selectionList.selectedIndex = 1
//            case .Balanced:
//                selectionList.selectedIndex = 2
//            case .Backload:
//                selectionList.selectedIndex = 3
//        }
//
//        return selectionList
//    }()
    
    let wakeUpTimeLabel: UILabel = {
        let label = TitleLabel(withText: "Wake time:", ofSize: DEFAULT_FONT_SIZE)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let wakeUpTimeSelector: UIDatePicker = {
        let dp = UIDatePicker()
        dp.minuteInterval = 30
        dp.datePickerMode = .time
        dp.translatesAutoresizingMaskIntoConstraints = false
        
        let initialTime = Authentication.shared.currentUser!.awakeInterval.startTime
        dp.setDate(Utility.timeToDate(time: initialTime), animated: false)
        
        return dp
    }()
    
    let bedTimeLabel: UILabel = {
        let label = TitleLabel(withText: "Bed time:", ofSize: DEFAULT_FONT_SIZE)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let bedTimeSelector: UIDatePicker = {
        let dp = UIDatePicker()
        let calendar = Calendar.current
        var dateComponents = DateComponents()

        // Set minimum time (8:00 PM)
        dateComponents.hour = 20
        dateComponents.minute = 0
        let minimumDate = calendar.date(from: dateComponents)
        dp.minimumDate = minimumDate
        
        // Set maximum time (e.g., 12:00 AM)
        dateComponents.hour = 23
        dateComponents.minute = 59
        let maximumDate = calendar.date(from: dateComponents)
        dp.maximumDate = maximumDate
        
        dp.minuteInterval = 1
        dp.datePickerMode = .time
        dp.translatesAutoresizingMaskIntoConstraints = false
        
        let initialTime = Authentication.shared.currentUser!.awakeInterval.endTime
        dp.setDate(Utility.timeToDate(time: initialTime), animated: false)
        
        return dp
    }()
    
//    let breakTimeLabel: UILabel = {
//        let label = TitleLabel(withText: "Break range:", ofSize: DEFAULT_FONT_SIZE)
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        return label
//    }()
    
    // TODO: Make custom view for break range selector
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preferences"
        view.backgroundColor = .white
        
        // productivityStyleList.addTarget(self, action: #selector(selectionChanged), for: .valueChanged)
        wakeUpTimeSelector.addTarget(self, action: #selector(wakeUpTimeChanged), for: .valueChanged)
        bedTimeSelector.addTarget(self, action: #selector(bedTimeChanged), for: .valueChanged)
        
        let wakeUpStack = UIStackView()
        wakeUpStack.axis = .horizontal
        wakeUpStack.distribution = .equalSpacing
        wakeUpStack.addArrangedSubview(wakeUpTimeLabel)
        wakeUpStack.addArrangedSubview(wakeUpTimeSelector)
        wakeUpStack.translatesAutoresizingMaskIntoConstraints = false
        
        let bedTimeStack = UIStackView()
        bedTimeStack.axis = .horizontal
        bedTimeStack.distribution = .equalSpacing
        bedTimeStack.addArrangedSubview(bedTimeLabel)
        bedTimeStack.addArrangedSubview(bedTimeSelector)
        bedTimeStack.translatesAutoresizingMaskIntoConstraints = false
        
        
//        view.addSubview(productivityStyleLabel)
//        view.addSubview(productivityStyleList)
        view.addSubview(wakeUpStack)
        view.addSubview(bedTimeStack)
//        view.addSubview(breakTimeLabel)
        
        NSLayoutConstraint.activate([
//            productivityStyleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
//            productivityStyleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            productivityStyleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//
//            productivityStyleList.topAnchor.constraint(equalTo: productivityStyleLabel.bottomAnchor, constant: 5),
//            productivityStyleList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            productivityStyleList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            wakeUpStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            wakeUpStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wakeUpStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            bedTimeStack.topAnchor.constraint(equalTo: wakeUpStack.bottomAnchor, constant: 10),
            bedTimeStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bedTimeStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            breakTimeLabel.topAnchor.constraint(equalTo: bedTimeStack.bottomAnchor, constant: 20),
//            breakTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            breakTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
//    @objc private func selectionChanged() {
//        let index = productivityStyleList.selectedIndex
//        let currentUser = Authentication.shared.currentUser!
//        if index == 0 {
//            currentUser.productivityStyle = .Dynamic
//        } else if index == 1 {
//            currentUser.productivityStyle = .Frontload
//        } else if index == 2 {
//            currentUser.productivityStyle = .Balanced
//        } else if index == 3 {
//            currentUser.productivityStyle = .Backload
//        }
//        Database.shared.updateUser(currentUser, nil)
//    }
    
    @objc private func wakeUpTimeChanged() {
        let currentUser = Authentication.shared.currentUser!
        let wakeUpTime = Time(fromString: wakeUpTimeSelector.date.formatted(date: .omitted, time: .shortened))
        let bedTime = Authentication.shared.currentUser!.awakeInterval.endTime
        currentUser.awakeInterval = DayInterval(startTime: wakeUpTime, endTime: bedTime)
        Database.shared.updateUser(currentUser, nil)
    }
    
    @objc private func bedTimeChanged() {
        let currentUser = Authentication.shared.currentUser!
        let wakeUpTime = Authentication.shared.currentUser!.awakeInterval.startTime
        let bedTime = Time(fromString: bedTimeSelector.date.formatted(date: .omitted, time: .shortened))
        currentUser.awakeInterval = DayInterval(startTime: wakeUpTime, endTime: bedTime)
        Database.shared.updateUser(currentUser, nil)
    }
}
