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
        stack.spacing = 50
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let titleTextField: LabeledTextField = {
        let tf = LabeledTextField(title: "Title:")
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let durationPickerTitle = TitleLabel(withText: "Hours", ofSize: DEFAULT_FONT_SIZE-2)
    
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
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
//        view.addSubview(titleTextField)
//        view.addSubview(deadlineView)
//
//        NSLayoutConstraint.activate([
//            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
//            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentEdgeInset.left),
//            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentEdgeInset.right),
//
//            deadlineView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 50),
//            deadlineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentEdgeInset.left),
//            deadlineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentEdgeInset.right)
//        ])
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
        
        if currentTask.timeTicks == 0 {
            // Then remove the current task
            let index = Authentication.shared.currentUser!.tasks.firstIndex { task in
                return task.id == currentTask.id
            }
            Authentication.shared.currentUser!.tasks.remove(at: index!)
        }
        
        tableView.reloadData()
    }
}
