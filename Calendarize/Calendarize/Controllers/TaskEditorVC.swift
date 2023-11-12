//
//  TaskEditorVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation
import UIKit

class TaskEditorVC: UIViewController {
    
    private let contentEdgeInset = UIEdgeInsets(top: 120, left: 40, bottom: 30, right: 40)
    
    let currentTask: Task!
    
    let isNewTask: Bool!
    
    let tableView: UITableView!
    
    let titleTextField: LabeledTextField = {
        let tf = LabeledTextField(title: "Title")
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let priorityLabel = TitleLabel(withText: "Priority", ofSize: DEFAULT_FONT_SIZE-2)
    
    let prioritySwitch: UISwitch = {
        let prioritySwitch = UISwitch()
        prioritySwitch.onTintColor = .primary
        
        prioritySwitch.translatesAutoresizingMaskIntoConstraints = false
        return prioritySwitch
    }()
    
    let durationPickerTitle = TitleLabel(withText: "Hours", ofSize: DEFAULT_FONT_SIZE-2)
    
    let durationPicker: TimeStepperView!
    
    let deadlinePickerTitle = TitleLabel(withText: "Deadline", ofSize: DEFAULT_FONT_SIZE-2)
    
    let deadlinePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .dateAndTime
        dp.minuteInterval = 5
        dp.preferredDatePickerStyle = .inline
        
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    
    init(withInitialTask task: Task, tableView: UITableView, isNewTask: Bool) {
        self.currentTask = task
        self.tableView = tableView
        self.isNewTask = isNewTask
        self.durationPicker = TimeStepperView(forTask: currentTask)
        
        super.init(nibName: nil, bundle: nil)
        
        titleTextField.textField.text = task.name
        prioritySwitch.isOn = task.type == .priority
        deadlinePicker.setDate(task.deadline, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        title = "Edit Task"
        
        view.backgroundColor = .background
        
        let durationView = UIView()
        durationView.translatesAutoresizingMaskIntoConstraints = false
        durationView.addSubview(durationPickerTitle)
        durationView.addSubview(durationPicker)
        NSLayoutConstraint.activate([
            durationPickerTitle.leadingAnchor.constraint(equalTo: durationView.leadingAnchor),
            durationPickerTitle.topAnchor.constraint(equalTo: durationView.topAnchor),
            durationPickerTitle.bottomAnchor.constraint(equalTo: durationView.bottomAnchor),
            durationPicker.trailingAnchor.constraint(equalTo: durationView.trailingAnchor),
            durationPicker.centerYAnchor.constraint(equalTo: durationView.centerYAnchor)
        ])
        
        let priorityView = UIView()
        priorityView.translatesAutoresizingMaskIntoConstraints = false
        priorityView.addSubview(priorityLabel)
        priorityView.addSubview(prioritySwitch)
        NSLayoutConstraint.activate([
            priorityLabel.leadingAnchor.constraint(equalTo: priorityView.leadingAnchor),
            priorityLabel.topAnchor.constraint(equalTo: priorityView.topAnchor),
            priorityLabel.bottomAnchor.constraint(equalTo: priorityView.bottomAnchor),
            prioritySwitch.trailingAnchor.constraint(equalTo: priorityView.trailingAnchor),
            prioritySwitch.centerYAnchor.constraint(equalTo: priorityView.centerYAnchor)
        ])
        
        let deadlineView = UIView()
        deadlineView.translatesAutoresizingMaskIntoConstraints = false
        deadlineView.addSubview(deadlinePickerTitle)
        deadlineView.addSubview(deadlinePicker)
        NSLayoutConstraint.activate([
            deadlinePickerTitle.leadingAnchor.constraint(equalTo: deadlineView.leadingAnchor),
            deadlinePickerTitle.topAnchor.constraint(equalTo: deadlineView.topAnchor),
            deadlinePickerTitle.trailingAnchor.constraint(equalTo: deadlineView.trailingAnchor),
            deadlinePicker.centerXAnchor.constraint(equalTo: deadlineView.centerXAnchor),
            deadlinePicker.bottomAnchor.constraint(equalTo: deadlineView.bottomAnchor),
            deadlinePickerTitle.bottomAnchor.constraint(equalTo: deadlinePicker.topAnchor)
        ])
        
        view.addSubview(titleTextField)
        view.addSubview(priorityView)
        view.addSubview(durationView)
        view.addSubview(deadlineView)

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentEdgeInset.left),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentEdgeInset.right),
            titleTextField.heightAnchor.constraint(equalToConstant: 70),
            
            priorityView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            priorityView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentEdgeInset.left),
            priorityView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentEdgeInset.right),
            priorityView.heightAnchor.constraint(equalToConstant: 50),
            
            durationView.topAnchor.constraint(equalTo: priorityView.bottomAnchor, constant: 20),
            durationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentEdgeInset.left),
            durationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentEdgeInset.right),
            durationView.heightAnchor.constraint(equalToConstant: 70),
            
            deadlineView.topAnchor.constraint(equalTo: durationView.bottomAnchor, constant: 20),
            deadlineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentEdgeInset.left),
            deadlineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentEdgeInset.right)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let currentUser = Authentication.shared.currentUser!
        
        guard let name = titleTextField.text else { return }
        if name == "" { return }
        
        currentTask.name = name
        currentTask.deadline = deadlinePicker.date
        
        let prevType = currentTask.type
        if prioritySwitch.isOn {
            currentTask.type = .priority
        } else {
            currentTask.type = .current
        }
        
        if isNewTask {
            if currentTask.timeTicks == 0 {
                return
            } else if currentTask.type == .priority {
                currentUser.priorityTasks.append(currentTask)
            } else {
                currentUser.regularTasks.append(currentTask)
            }
        } else {
            if currentTask.timeTicks == 0 {
                if prevType == .priority{
                    let index = currentUser.priorityTasks.firstIndex { task in
                        task.id == currentTask.id
                    }
                    currentUser.priorityTasks.remove(at: index!)
                } else {
                    let index = currentUser.regularTasks.firstIndex { task in
                        task.id == currentTask.id
                    }
                    currentUser.regularTasks.remove(at: index!)
                }
            } else if prevType != currentTask.type {
                if prevType == .priority {
                    // move to regular tasks
                    let index = currentUser.priorityTasks.firstIndex { task in
                        task.id == currentTask.id
                    }
                    currentUser.priorityTasks.remove(at: index!)
                    currentUser.regularTasks.append(currentTask)
                } else {
                    // move to priority tasks
                    let index = currentUser.regularTasks.firstIndex { task in
                        task.id == currentTask.id
                    }
                    currentUser.regularTasks.remove(at: index!)
                    currentUser.priorityTasks.append(currentTask)
                }
            }
        }
        
        tableView.reloadData()
    }
}
