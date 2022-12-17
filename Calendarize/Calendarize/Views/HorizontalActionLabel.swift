//
//  HorizontalActionLabel.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import UIKit

/* A label with an embedded button inside the text. */
class HorizontalActionLabel: UIStackView {

    let label: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryText
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.primary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return button
    }()
    
    init(frame: CGRect = .zero, label: String, buttonTitle: String) {
        super.init(frame: frame)
        self.label.text = label
        self.button.setTitle(buttonTitle, for: .normal)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addArrangedSubview(label)
        addArrangedSubview(button)
        axis = .horizontal
        distribution = .equalSpacing
        spacing = 2
        backgroundColor = .clear
    }
    
    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        button.addTarget(target, action: action, for: event)
    }
}
