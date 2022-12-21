//
//  TasksVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation
import UIKit

class TasksVC: UITableViewController {
    
    // The shared TasksVC for the current user
    static var shared: TasksVC!
    
    // tasksForTableView[0] contains all priority tasks
    // tasksForTableView[1] contains all non-priority tasks
    // var tasksForTableView: [[Task]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tasks"
        
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didTapCreateNewTask))
        navigationItem.rightBarButtonItem = plusButton
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Authentication.shared.currentUser!.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseIdentifier, for: indexPath) as! TaskCell
        cell.task = Authentication.shared.currentUser!.tasks[indexPath.item]
        print("called cell for row at")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Open up TaskEditorVC with the current task's info prefilled
        let selectedTask = Authentication.shared.currentUser!.tasks[indexPath.item]
        let vc = TaskEditorVC(withInitialTask: selectedTask, tableView: tableView, isNewTask: false)
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title:  "Done", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            Authentication.shared.currentUser!.tasks.remove(at: indexPath.item)
            tableView.reloadData()
            success(true)
        })
        doneAction.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    @objc func didTapCreateNewTask() {
        let newTask = Task(name: "", timeTicks: 1, deadline: Date())
        let vc = TaskEditorVC(withInitialTask: newTask, tableView: tableView, isNewTask: true)
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapRefresh() {
        // regenerate a calendar
        // MARK: completion here should be reloadCalendar()
//        Database.shared.updateUser(Authentication.shared.currentUser, nil)
//        navigationController?.popViewController(animated: true)
    }
}

class TaskCell: UITableViewCell {
    static let reuseIdentifier = "TaskCell"
    
    let timeStepper = AutoDeleteTimeStepperView()
    
    let taskLabel = ContentLabel(withText: "", ofSize: 18)
    
    let deadlineLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .secondaryText
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    // The Task instance associated with this cell
    var task: Task? {
        didSet {
            guard let task = task else { return }
            timeStepper.setTask(task: task)
            taskLabel.text = task.name
            deadlineLabel.text = Utility.dateToString(task.deadline)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Set constraints for UIViews
        contentView.addSubview(taskLabel)
        contentView.addSubview(deadlineLabel)
        contentView.addSubview(timeStepper)
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 70),
            
            taskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            deadlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),
            deadlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timeStepper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            timeStepper.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didChangeTabs() {
        // Load the current todo-list state into firebase
        // Delete current schedule
        // Run algorithm
        // Add new schedule
    }
}

class AutoDeleteTimeStepperView: TimeStepperView {
    // Now, tapping decrement can actually delete a task from currentUser.
    
    override func didTapDecrement() {
        super.didTapDecrement()
        
        if associatedTask.timeTicks == 0 {
            // Then remove the current task
            let index = Authentication.shared.currentUser!.tasks.firstIndex { task in
                return task.id == associatedTask.id
            }
            Authentication.shared.currentUser!.tasks.remove(at: index!)
        }
        TasksVC.shared.tableView.reloadData()
    }
}
