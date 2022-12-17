//
//  MediumLabel.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import UIKit

class MediumLabel: UILabel {
    init(_ text: String) {
        super.init(frame: .infinite)
        self.textColor = .secondaryText
        self.font = .systemFont(ofSize: 17, weight: .medium)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
