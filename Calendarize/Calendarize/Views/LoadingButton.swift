//
//  LoadingButton.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import UIKit

/* A button that will show activity indicator when loading. */
class LoadingButton: UIButton {
    
    struct ButtonState {
        var state: UIControl.State
        var title: String?
        var image: UIImage?
    }
    
    private (set) var buttonStates: [ButtonState] = []

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .white
        indicator.hidesWhenStopped = true
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
        var buttonStates: [ButtonState] = []
        for state in [UIControl.State.disabled] {
            let buttonState = ButtonState(state: state, title: title(for: state), image: image(for: state))
            buttonStates.append(buttonState)
            setTitle("", for: state)
            setImage(UIImage(), for: state)
        }
        self.buttonStates = buttonStates
        isEnabled = false
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
        for buttonState in buttonStates {
            setTitle(buttonState.title, for: buttonState.state)
            setImage(buttonState.image, for: buttonState.state)
        }
        isEnabled = true
    }
    
    private func configure() {
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
