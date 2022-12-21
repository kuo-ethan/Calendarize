//
//  TimeStepperView.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import UIKit

class TimeStepperView: UIStackView {
    
    var associatedTask: Task!
    
    let incrButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "arrowtriangle.up.fill"), for: .normal)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let timeLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let decrButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "arrowtriangle.down.fill"), for: .normal)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    init() {
        self.associatedTask = nil
        super.init(frame: .zero)
        timeLabel.text = "1"
        
        configure()
    }
    
    init(forTask task: Task) {
        self.associatedTask = task
        super.init(frame: .zero)
        timeLabel.text = Utility.timeTicksToStringInHours(associatedTask.timeTicks)
        
        configure()
    }
    
    func setTask(task: Task) {
        associatedTask = task
        timeLabel.text = Utility.timeTicksToStringInHours(associatedTask.timeTicks)
    }
    
    private func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(incrButton)
        addSubview(timeLabel)
        addSubview(decrButton)
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 40),
            self.heightAnchor.constraint(equalToConstant: 65),
            
            timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            incrButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            incrButton.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: 0),
            incrButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            incrButton.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1),
            
            decrButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            decrButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 0),
            decrButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            decrButton.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1),
        ])
        
        incrButton.addTarget(self, action: #selector(didTapIncrement), for: .touchUpInside)
        decrButton.addTarget(self, action: #selector(didTapDecrement), for: .touchUpInside)
    }
    
    @objc func didTapIncrement() {
        // Don't let timeTicks go above 40
        if associatedTask.timeTicks == 40 {
            return
        }
        associatedTask.timeTicks += 1
        timeLabel.text = Utility.timeTicksToStringInHours(associatedTask.timeTicks)
        for task in Authentication.shared.currentUser!.tasks {
            print(task.toString())
        }
        print("===================")
    }
    
    @objc func didTapDecrement() {
        // Don't let timeTicks go below 0
        if associatedTask.timeTicks == 0 {
            return
        }
        associatedTask.timeTicks -= 1
        // Database.shared.updateUser(Authentication.shared.currentUser!, nil)
        timeLabel.text = Utility.timeTicksToStringInHours(associatedTask.timeTicks)
        for task in Authentication.shared.currentUser!.tasks {
            print(task.toString())
        }
        print("===================")
    }
    
    func currentTimeTicks() -> TimeTicks {
        return associatedTask.timeTicks
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
