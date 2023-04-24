//
//  CKWrapper.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation

import Foundation
import CalendarKit
import UIKit

// All types of calendar kit events.
enum CKEventType: String, Codable {
    case Habit, PriorityTask, CurrentTask, Checkpoint
}
// An event only to be displayed in calendar kit.
struct CKEvent: Codable {
    var startDate: Date
    var endDate: Date
    var title: String
    let type: CKEventType
}

final class CKWrapper: EventDescriptor {
    
    public private(set) var ckEvent: CKEvent
    
    public var dateInterval: DateInterval {
        get {
            return DateInterval(start: ckEvent.startDate, end: ckEvent.endDate)
        }
        set {
            ckEvent.startDate = newValue.start
            ckEvent.endDate = newValue.end
        }
    }
    public let isAllDay: Bool = false
    
    public var text: String {
        get {
            return ckEvent.title
        }
        set {
            ckEvent.title = newValue
        }
    }
    public var attributedText: NSAttributedString?
    public var lineBreakMode: NSLineBreakMode?
    public var color: UIColor {
        get {
            switch (ckEvent.type) {
            case .Habit:
                return .habitEventColor
            case.CurrentTask:
                return .imminentTaskEventColor
            case.PriorityTask:
                return .priorityTaskEventColor
            case.Checkpoint:
                return .checkpointEventColor
            }
        }
    }
    public var backgroundColor = SystemColors.systemBlue.withAlphaComponent(0.3)
    public var textColor = SystemColors.label
    public var font = UIFont.boldSystemFont(ofSize: 12)
    public weak var editedEvent: EventDescriptor? {
        didSet {
            updateColors()
        }
    }
    
    public init(calendarKitEvent: CKEvent) {
        self.ckEvent = calendarKitEvent
        updateColors()
    }
    
    public func makeEditable() -> CKWrapper {
        let cloned = Self(calendarKitEvent: ckEvent)
        cloned.editedEvent = self
        return cloned
    }
    
    public func commitEditing() {
        guard let edited = editedEvent else {return}
        edited.dateInterval = dateInterval
    }
    
    private func updateColors() {
        (editedEvent != nil) ? applyEditingColors() : applyStandardColors()
    }
    
    /// Colors used when event is not in editing mode
    private func applyStandardColors() {
        backgroundColor = dynamicStandardBackgroundColor()
        textColor = dynamicStandardTextColor()
    }
    
    /// Colors used in editing mode
    private func applyEditingColors() {
        backgroundColor = color.withAlphaComponent(0.95)
        textColor = .white
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private func dynamicStandardBackgroundColor() -> UIColor {
        let light = backgroundColorForLightTheme(baseColor: color)
        let dark = backgroundColorForDarkTheme(baseColor: color)
        return dynamicColor(light: light, dark: dark)
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private func dynamicStandardTextColor() -> UIColor {
        let light = textColorForLightTheme(baseColor: color)
        return dynamicColor(light: light, dark: color)
    }
    
    private func textColorForLightTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }
    
    private func backgroundColorForLightTheme(baseColor: UIColor) -> UIColor {
        baseColor.withAlphaComponent(0.3)
    }
    
    private func backgroundColorForDarkTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a * 0.8)
    }
    
    private func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                let interfaceStyle = traitCollection.userInterfaceStyle
                switch interfaceStyle {
                case .dark:
                    return dark
                default:
                    return light
                }
            }
        } else {
            return light
        }
    }
}
