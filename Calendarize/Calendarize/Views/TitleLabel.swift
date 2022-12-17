//
//  TitleLabel.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import UIKit

class TitleLabel: UILabel {
    
    init(withText text: String, ofSize size: Double) {
        super.init(frame: .zero)
        self.text = text.uppercased()
        self.sizeToFit()
        self.textColor = .secondaryText
        self.numberOfLines = 1
        self.textAlignment = .left
        self.font = .systemFont(ofSize: DEFAULT_FONT_SIZE-1, weight: .semibold)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
