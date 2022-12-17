//
//  ProfileVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation
import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    private let nameLabel = TitleLabel(withText: "Name: ", ofSize: DEFAULT_FONT_SIZE)
    
    private let nameValueLabel = ContentLabel(withText: "", ofSize: DEFAULT_FONT_SIZE-1)
    
    private let emailLabel = TitleLabel(withText: "Email: ", ofSize: DEFAULT_FONT_SIZE)
    
    private let emailValueLabel = ContentLabel(withText: "", ofSize: DEFAULT_FONT_SIZE-1)
    
    private let habitsActionLabel: HorizontalActionLabel = {
        let actionLabel = HorizontalActionLabel(
            label: "Update your habits ",
            buttonTitle: "here")
        
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        return actionLabel
    }()
    
    private let contentEdgeInset = UIEdgeInsets(top: 120, left: 40, bottom: 30, right: 40)
    
    // Add button for editing habits list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        title = "Profile"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(didTapBackButton))
        // backButton.tintColor = .primary
        let signOutButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapSignOut))
        // signOutButton.tintColor = .primary
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = signOutButton
        
        view.addSubview(nameLabel)
        view.addSubview(nameValueLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailValueLabel)
        view.addSubview(habitsActionLabel)
        
        if let fullname = Authentication.shared.currentUser?.fullname {
            nameValueLabel.text = fullname
        }
        
        if let email = Authentication.shared.currentUser?.email {
            emailValueLabel.text = email
        }
        
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: 50),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: contentEdgeInset.left),
            nameValueLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            nameValueLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 5),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                               constant: 10),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailValueLabel.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor),
            emailValueLabel.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 5),
            habitsActionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitsActionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        habitsActionLabel.addTarget(self, action: #selector(didTapUpdateHabits), for: .touchUpInside)
    }
    
    @objc func didTapUpdateHabits() {
        navigationController?.pushViewController(HabitsVC(), animated: true)
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSignOut() {
        do {
            Authentication.shared.unlinkCurrentUser()
            try FirebaseAuth.Auth.auth().signOut()
        } catch { return }
        
        guard let window = self.view.window else { return }
        
        window.rootViewController = UINavigationController(rootViewController: SignInVC())
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.3
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: nil)
    }
}
