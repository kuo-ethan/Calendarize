//
//  HabitEditorVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation
import UIKit
import TagListView

private let TAG_COLOR = UIColor(hex: "#e6e6e6")!

private let TAG_SELECTED_COLOR = UIColor(hex: "#fb8886")!

class HabitEditorVC: UIViewController {
    
    let habitTagsDelegate = HabitTagsDelegate()
    
    let dayTagsDelegate = DayTagsDelegate()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 25

        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let tagStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let tagLabel = ContentLabel(withText: "Tag:", ofSize: 14)
    
    private let customTagTextField = ContentTextField(initialText: "")
    
    private let tagListView: TagListView = {
        let tlv = TagListView()
        tlv.textColor = .black
        tlv.textFont = .systemFont(ofSize: DEFAULT_FONT_SIZE-1)
        tlv.borderColor = .black
        tlv.paddingX = 7
        tlv.paddingY = 3
        tlv.marginX = 7
        tlv.marginY = 5
        tlv.cornerRadius = 8
        
        tlv.enableRemoveButton = true
        tlv.removeIconLineColor = .white
        tlv.removeButtonIconSize = 6
        
        tlv.tagBackgroundColor = TAG_COLOR
        
        tlv.alignment = .center
        tlv.addTags(Authentication.shared.currentUser!.savedHabitTags)
        tlv.tagViews[0].tagBackgroundColor = TAG_SELECTED_COLOR
        tlv.translatesAutoresizingMaskIntoConstraints = false
        return tlv
    }()
    
    private let daysLabel = ContentLabel(withText: "Days:", ofSize: 14)
    
    private let dayTags: TagListView = {
        let tlv = TagListView()
        tlv.textColor = .black
        tlv.textFont = .systemFont(ofSize: DEFAULT_FONT_SIZE-1)
        tlv.borderColor = .black
        tlv.paddingX = 7
        tlv.paddingY = 3
        tlv.marginX = 7
        tlv.marginY = 5
        tlv.cornerRadius = 8
        
        tlv.tagBackgroundColor = TAG_COLOR
        
        tlv.alignment = .center
        tlv.addTags(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"])
        tlv.tagViews[0].tagBackgroundColor = TAG_SELECTED_COLOR
        tlv.translatesAutoresizingMaskIntoConstraints = false
        return tlv
    }()
    
    private let durationLabel = ContentLabel(withText: "Duration:", ofSize: 14)
    
    private let durationScrollablePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.minuteInterval = 5
        dp.datePickerMode = .countDownTimer
        
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    private let fromStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 25

        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let fromLabel = ContentLabel(withText: "From:", ofSize: 14)
    
    private let fromTimeScrollablePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.minuteInterval = 5
        dp.datePickerMode = .time
        
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    private let toStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 25

        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let toLabel = ContentLabel(withText: "To:", ofSize: 14)
    
    private let toTimeScrollablePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.minuteInterval = 5
        dp.datePickerMode = .time
        
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    private let contentEdgeInset = UIEdgeInsets(top: 120, left: 40, bottom: 30, right: 40)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        title = "Add Habit"
        hideKeyboardWhenTappedAround()
        
        customTagTextField.registerCompletion(completion: didTapSubmitCustomTag)
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(didTapBackButton))
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(didTapSaveHabit))
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = saveButton
        
        tagListView.delegate = habitTagsDelegate
        dayTags.delegate = dayTagsDelegate
        
        tagStack.addArrangedSubview(tagLabel)
        tagStack.addArrangedSubview(customTagTextField)
        
        fromStack.addArrangedSubview(fromLabel)
        fromStack.addArrangedSubview(fromTimeScrollablePicker)
        
        toStack.addArrangedSubview(toLabel)
        toStack.addArrangedSubview(toTimeScrollablePicker)
        
        view.addSubview(stack)
        stack.addArrangedSubview(tagStack)
        stack.addArrangedSubview(tagListView)
        stack.addArrangedSubview(daysLabel)
        stack.addArrangedSubview(dayTags)
        stack.addArrangedSubview(durationLabel)
        stack.addArrangedSubview(durationScrollablePicker)
        stack.addArrangedSubview(fromStack)
        stack.addArrangedSubview(toStack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                           constant: contentEdgeInset.left),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                            constant: -contentEdgeInset.right),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
        ])
    }
    
    @objc private func didTapSaveHabit() {
        saveHabit()
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func didTapSubmitCustomTag() {
        
        print("Called didTapSubmitCustomTag")
        guard let currentText = customTagTextField.text else { return }
        guard let currentUser = Authentication.shared.currentUser else { return }
        if currentText == "" || currentUser.savedHabitTags.contains(currentText) {
            return
        }
        tagListView.addTag(currentText)
        currentUser.savedHabitTags.append(currentText)
        Database.shared.updateUser(currentUser, nil)
        
        customTagTextField.text = ""
    }
    
    // Returns whether this habit is feasible and non-overlapping.
    private func validate(newHabit habit: Habit, among existingHabits: [Habit]) -> Bool {
        let start = habit.dayInterval.startTime
        let end = habit.dayInterval.endTime
        let interval = (end.hour * 60 + end.minutes) - (start.hour * 60 + start.minutes)
        
        if interval <= 0 {
            print("ERROR: End time must be after start time.")
            return false
        } else if interval < habit.minutes {
            print("ERROR: Habit cannot be completed in the time period.")
            return false
        }
        
        // Check overlap
        for existingHabit in existingHabits {
            if existingHabit.dayOfWeek == habit.dayOfWeek {
                let existingStart = existingHabit.dayInterval.startTime
                let existingEnd = existingHabit.dayInterval.endTime
                if (existingStart < start && start < existingEnd) || (existingStart < end && end < existingEnd) || (start < existingStart && existingEnd < end) {
                    print("ERROR: Habit time interval cannot overlap an existing habit.")
                    return false
                }
            }
        }
        
        return true
    }
    
    private func saveHabit() {
        
        let currentTag = tagListView.tagViews[habitTagsDelegate.selectedTagIndex]
        let currentHabitType = currentTag.currentTitle!
        
        var instances: [Habit] = []
        
        let minutes = Int(durationScrollablePicker.countDownDuration / 60)
        let startTime = fromTimeScrollablePicker.date.formatted(date: .omitted, time: .shortened)
        let endTime = toTimeScrollablePicker.date.formatted(date: .omitted, time: .shortened)
        let timeFrame = DayInterval(startTime: Time(fromString: startTime), endTime: Time(fromString: endTime))
        
        for index in dayTagsDelegate.selectedDayIndices {
            // create a commitment instance for that day
            let dayOfWeek = DayOfWeek(rawValue: index)!
            instances.append(Habit(id: UUID(), type: currentHabitType, minutes: minutes, dayOfWeek: dayOfWeek, dayInterval: timeFrame))
        }
        
        guard let currentUser = Authentication.shared.currentUser else { return }
        
        // MARK: Need to check that these habit instances are feasible and non-overlapping.
        var existingHabits: [Habit] = []
        for habitType in currentUser.habits.keys {
            existingHabits.append(contentsOf: currentUser.habits[habitType]!)
            
        }
        for habit in instances {
            if !validate(newHabit: habit, among: existingHabits) {
                return
            }
        }
        
        for habitType in currentUser.habits.keys {
            if habitType == currentHabitType {
                currentUser.habits[habitType]!.append(contentsOf: instances)
                Database.shared.updateUser(currentUser) { error in
                    if let _ = error {
                        fatalError("Failed to write to existing habit in Firestore")
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                return
            }
        }
        // Adding a new type of commitment
        currentUser.habits[currentHabitType] = instances
        Database.shared.updateUser(currentUser) { error in
            if let _ = error {
                fatalError("Failed to write new habit into Firestore")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

class HabitTagsDelegate: TagListViewDelegate {
    
    var selectedTagIndex = 0
    
    // MARK: add a separate button for 'editing' commitment tags (deletion)
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.tagViews[selectedTagIndex].tagBackgroundColor = TAG_COLOR
        selectedTagIndex = sender.tagViews.firstIndex(of: tagView)!
        tagView.tagBackgroundColor = TAG_SELECTED_COLOR
        print(selectedTagIndex)
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        // Make sure not attempting to remove selected tag
        let currentUser = Authentication.shared.currentUser!
        guard let index = currentUser.savedHabitTags.firstIndex(of: title) else {
            fatalError("Tag to remove wasn't saved.")
        }
        if selectedTagIndex == index {
            print("Cannot remove selected tag.")
            return
        }
        // Make sure selectedTagIndex is still correct post-removal
        if selectedTagIndex > index {
            selectedTagIndex -= 1
        }
        
        // Remove tag from the tag list UI
        sender.removeTagView(tagView)
        
        // Remove tag from the user's saved habit tags list
        currentUser.savedHabitTags.remove(at: index)
        Database.shared.updateUser(currentUser) { error in
            if let _ = error {
                fatalError("Failed to write user to Firestore")
            } else {
                print("successfully removed a saved habit tag")
            }
        }
        print(selectedTagIndex)
    }
}

class DayTagsDelegate: TagListViewDelegate {
    
    var selectedDayIndices = Set([0])
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        let currIndex = sender.tagViews.firstIndex(of: tagView)!
        if (selectedDayIndices.contains(currIndex)) {
            // Already selected
            selectedDayIndices.remove(currIndex)
            sender.tagViews[currIndex].tagBackgroundColor = TAG_COLOR
        } else {
            // Not selected
            selectedDayIndices.insert(currIndex)
            sender.tagViews[currIndex].tagBackgroundColor = TAG_SELECTED_COLOR
        }
        print(selectedDayIndices)
    }
}

/* A textfield with no label above it. */
class ContentTextField: UIView, UITextFieldDelegate {

    let textField: UITextField = {
        let tf = TextField()
        tf.borderStyle = .none
        tf.backgroundColor = UIColor(hex: "#f7f7f7")
        tf.textColor = .primaryText
        tf.font = .systemFont(ofSize: DEFAULT_FONT_SIZE, weight: .medium)
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "Enter custom tag"
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    var completion: (() -> Void)?
    
    private var textFieldHeightConstraint: NSLayoutConstraint!
    
    init(initialText: String) {
        super.init(frame: .zero)
        self.textField.text = initialText
        configure()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
     func registerCompletion(completion: (() -> Void)?) {
        self.completion = completion
    }
    
    private func configure() {
        
        addSubview(textField)
        
        textField.delegate = self

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        let height = DEFAULT_FONT_SIZE * 2
        textFieldHeightConstraint = textField.heightAnchor.constraint(
            equalToConstant: height)
        textFieldHeightConstraint.isActive = true
        textField.layer.cornerRadius = height / 2
    }
    
    private class TextField: UITextField {
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 20, dy: 0)
        }
        
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 20, dy: 0)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let completion = self.completion {
            completion()
        }
        return true
    }
}
