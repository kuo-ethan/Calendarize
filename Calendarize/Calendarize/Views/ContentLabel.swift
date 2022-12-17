//
//  ContentLabel.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/14/22.
//

import UIKit

class ContentLabel: UILabel {
    
    init(withText text: String, ofSize size: CGFloat) {
        super.init(frame: .zero)
        self.text = text
        self.textColor = .primaryText
        self.font = .systemFont(ofSize: size, weight: .medium)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
