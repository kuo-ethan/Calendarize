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
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 25
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let titleTextField: LabeledTextField = {
        let tf = LabeledTextField(title: "Title:")
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let durationPickerTitle = TitleLabel(withText: "Duration", ofSize: DEFAULT_FONT_SIZE-2)
    
    let durationPicker: TimeStepperView!
    
    let deadlinePickerTitle = TitleLabel(withText: "Deadline", ofSize: DEFAULT_FONT_SIZE-2)
    
    let deadlinePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .dateAndTime
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
        deadlinePicker.setDate(task.deadline, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Task"
        
        view.backgroundColor = .systemBackground
        
        let durationView = UIView()
        durationView.translatesAutoresizingMaskIntoConstraints = false
        durationView.addSubview(durationPickerTitle)
        durationView.addSubview(durationPicker)
        NSLayoutConstraint.activate([
            durationPickerTitle.leadingAnchor.constraint(equalTo: durationView.leadingAnchor),
            durationPickerTitle.topAnchor.constraint(equalTo: durationView.topAnchor),
            durationPickerTitle.trailingAnchor.constraint(equalTo: durationView.trailingAnchor),
            durationPicker.leadingAnchor.constraint(equalTo: durationView.leadingAnchor),
            durationPicker.trailingAnchor.constraint(equalTo: durationView.trailingAnchor),
            durationPicker.bottomAnchor.constraint(equalTo: durationView.bottomAnchor),
            durationPickerTitle.bottomAnchor.constraint(equalTo: durationPicker.topAnchor, constant: -5)
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
            deadlinePickerTitle.bottomAnchor.constraint(equalTo: deadlinePicker.topAnchor, constant: -5)
        ])
        
        stack.addArrangedSubview(titleTextField)
        stack.addArrangedSubview(durationView)
        stack.addArrangedSubview(deadlineView)
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                           constant: contentEdgeInset.left),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                            constant: -contentEdgeInset.right),
//            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor,
//                                       constant: 0),
//            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor,
//                                       constant: -100),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let name = titleTextField.text else {
            return
        }
        if name == "" {
            return
        }
        
        // let timeTicks = durationPicker.currentTimeTicks()
        let deadline = deadlinePicker.date
        
        currentTask.name = name
        // currentTask.timeTicks = timeTicks
        currentTask.deadline = deadline
        
        if isNewTask {
            Authentication.shared.currentUser!.tasks.append(currentTask)
        }
        
        tableView.reloadData()
    }
}
