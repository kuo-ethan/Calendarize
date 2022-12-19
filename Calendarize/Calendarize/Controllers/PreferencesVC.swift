//
//  PreferencesVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/19/22.
//

import Foundation
import UIKit
import SelectionList

class PreferencesVC: UIViewController {
    
    let productivityStyleLabel: TitleLabel = {
        let label = TitleLabel(withText: "Productivity Style:", ofSize: DEFAULT_FONT_SIZE)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let productivityStyleList: SelectionList = {
        let selectionList = SelectionList()
        selectionList.items = ["Dynamic", "Frontload", "Balanced", "Backload"]
        selectionList.allowsMultipleSelection = false
        selectionList.isSelectionMarkTrailing = false
        selectionList.selectionImage = UIImage(systemName: "circle.fill")
        selectionList.deselectionImage = UIImage(systemName: "circle")
        selectionList.translatesAutoresizingMaskIntoConstraints = false
        
        return selectionList
    }()
    
    let wakeUpTimeLabel: UILabel = {
        let label = TitleLabel(withText: "Wake up time:", ofSize: DEFAULT_FONT_SIZE)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let wakeUpTimeSelector: UIDatePicker = {
        let dp = UIDatePicker()
        dp.minuteInterval = 30
        dp.datePickerMode = .time
        dp.translatesAutoresizingMaskIntoConstraints = false
        
        return dp
    }()
    
    let bedTimeLabel: UILabel = {
        let label = TitleLabel(withText: "Bed time:", ofSize: DEFAULT_FONT_SIZE)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let bedTimeSelector: UIDatePicker = {
        let dp = UIDatePicker()
        dp.minuteInterval = 30
        dp.datePickerMode = .time
        dp.translatesAutoresizingMaskIntoConstraints = false
        
        return dp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preferences"
        view.backgroundColor = .white
        
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
        
        view.addSubview(productivityStyleLabel)
        view.addSubview(productivityStyleList)
        view.addSubview(wakeUpStack)
        view.addSubview(bedTimeStack)
        
        NSLayoutConstraint.activate([
            productivityStyleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            productivityStyleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            productivityStyleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            productivityStyleList.topAnchor.constraint(equalTo: productivityStyleLabel.bottomAnchor, constant: 5),
            productivityStyleList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            productivityStyleList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            wakeUpStack.topAnchor.constraint(equalTo: productivityStyleList.bottomAnchor, constant: 40),
            wakeUpStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wakeUpStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            bedTimeStack.topAnchor.constraint(equalTo: wakeUpStack.bottomAnchor, constant: 10),
            bedTimeStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bedTimeStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
