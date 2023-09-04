//
//  ProfileVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation
import UIKit
// import FirebaseAuth

class ProfileVC: UIViewController {
    
    private let nameLabel = TitleLabel(withText: "Name: ", ofSize: DEFAULT_FONT_SIZE)
    
    private let nameValueLabel = ContentLabel(withText: "", ofSize: DEFAULT_FONT_SIZE-1)
    
    private let emailLabel = TitleLabel(withText: "Email: ", ofSize: DEFAULT_FONT_SIZE)
    
    private let emailValueLabel = ContentLabel(withText: "", ofSize: DEFAULT_FONT_SIZE-1)
    
    private let busynessIndexLabel: ContentLabel = {
        let label = ContentLabel(withText: "N/A", ofSize: 60)
        
        guard let val = Authentication.shared.currentUser!.busynessIndex else {
            return label
        }
        
        let busynessIndex = String(val)
        label.text = busynessIndex
        
        return label
    }()
    
    private var busynessIndexView: CircularProgressBarView!
    
    private let CIRCULAR_ANIMATION_DURATION: TimeInterval = 1
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let contentEdgeInset = UIEdgeInsets(top: 120, left: 40, bottom: 30, right: 40)
    
    
    private let CELLS = ["Preferences", "Update habits"]
    
    // Add button for editing habits list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .background
        title = "Profile"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(didTapBackButton))
        let signOutButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapSignOut))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = signOutButton
        
        // CALayer does not use constraints
        busynessIndexView = CircularProgressBarView(frame: .zero)
        busynessIndexView.translatesAutoresizingMaskIntoConstraints = false
        // busynessIndexView.center = view.center
        
        var toValue = 0.0
        if let val = Authentication.shared.currentUser!.busynessIndex {
            toValue = Double(val) / 100
        }
        
        busynessIndexView.progressAnimation(duration: CIRCULAR_ANIMATION_DURATION, toValue: toValue)
        view.addSubview(busynessIndexView)
        
        view.addSubview(nameLabel)
        view.addSubview(nameValueLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailValueLabel)
        view.addSubview(busynessIndexLabel)
        view.addSubview(tableView)
        
        if let fullname = Authentication.shared.currentUser?.fullName {
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
            
            busynessIndexLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            busynessIndexLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            busynessIndexView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            busynessIndexView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            busynessIndexView.widthAnchor.constraint(equalToConstant: 200),  // Assuming the desired width is 200, adjust accordingly
            busynessIndexView.heightAnchor.constraint(equalTo: busynessIndexView.widthAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSignOut() {
        Authentication.shared.signOut()
        
        guard let window = self.view.window else { return }
        
        window.rootViewController = UINavigationController(rootViewController: SignInVC())
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.3
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: nil)
    }
}

extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            navigationController?.pushViewController(PreferencesVC(), animated: true)
        } else if indexPath.item == 1 {
            navigationController?.pushViewController(HabitsVC(), animated: true)
        }
    }
}

extension ProfileVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CELLS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        let arrowImage = UIImageView(image: UIImage(systemName: "greaterthan"))
        arrowImage.frame = CGRect(x: 0, y: 0, width: 8, height: 13)
        cell.accessoryView = arrowImage
        var content = cell.defaultContentConfiguration()
        content.text = CELLS[indexPath.item]
        cell.contentConfiguration = content
        return cell
    }
    
}
