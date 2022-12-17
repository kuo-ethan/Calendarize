//
//  SignUpVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation
import UIKit
import NotificationBannerSwift
import FirebaseAuth

class SignUpVC: UIViewController {
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 25
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sign up"
        lbl.textColor = .primaryText
        lbl.font = .systemFont(ofSize: 30, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let titleSecLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Optimize your schedule today"
        lbl.textColor = .secondaryText
        lbl.font = .systemFont(ofSize: 17, weight: .medium)
        
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let fullNameTextField: LabeledTextField = {
        let tf = LabeledTextField(title: "Full Name:")
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let emailTextField: LabeledTextField = {
        let tf = LabeledTextField(title: "Email:")
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let passwordTextField: LabeledTextField = {
        let tf = LabeledTextField(title: "Password:")
        tf.textField.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let confirmPasswordTextField: LabeledTextField = {
        let tf = LabeledTextField(title: "Confirm Password:")
        tf.textField.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let signupButton: LoadingButton = {
        let btn = LoadingButton()
        btn.layer.backgroundColor = UIColor.primary.cgColor
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.isUserInteractionEnabled = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let contentEdgeInset = UIEdgeInsets(top: 120, left: 40, bottom: 30, right: 40)
    
    private let signupButtonHeight: CGFloat = 44.0

    private var bannerQueue = NotificationBannerQueue(maxBannersOnScreenSimultaneously: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        view.backgroundColor = .background
        
        view.addSubview(titleLabel)
        view.addSubview(titleSecLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: contentEdgeInset.left),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: contentEdgeInset.right),
            titleSecLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                               constant: 3),
            titleSecLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            titleSecLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        view.addSubview(stack)
        stack.addArrangedSubview(fullNameTextField)
        stack.addArrangedSubview(emailTextField)
        stack.addArrangedSubview(passwordTextField)
        stack.addArrangedSubview(confirmPasswordTextField)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                           constant: contentEdgeInset.left),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                            constant: -contentEdgeInset.right),
            stack.topAnchor.constraint(equalTo: titleSecLabel.bottomAnchor,
                                       constant: 40)
        ])
        
        view.addSubview(signupButton)
        NSLayoutConstraint.activate([
            signupButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            signupButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 30),
            signupButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            signupButton.heightAnchor.constraint(equalToConstant: signupButtonHeight)
        ])
        
        signupButton.layer.cornerRadius = signupButtonHeight / 2
        
        signupButton.addTarget(self, action: #selector(didTapSignUp(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapSignUp(_ sender: UIButton) {
        // Validate text fields are not empty
        guard let fullName = fullNameTextField.text, fullName != "" else {
            showErrorBanner(withTitle: "Missing name", subtitle: "Please enter your full name")
            return
        }
        
        guard let email = emailTextField.text, email != "" else {
            showErrorBanner(withTitle: "Missing email", subtitle: "Please enter your email address")
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            showErrorBanner(withTitle: "Missing password", subtitle: "Please enter your password")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword != "" else {
            showErrorBanner(withTitle: "Missing password confirmation", subtitle: "Please confirm your password")
            return
        }
        
        signupButton.showLoading()
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            defer {
                self.signupButton.hideLoading()
            }
            
            guard error == nil else {
                self.showErrorBanner(withTitle: "Failed to create account", subtitle: "Please try again")
                return
            }
            
            // Add new user to firestore (no habits yet)
            guard let authResult = result else { return }
            let newUser = User(email: email, fullname: fullName, habits: [], tasks: [])
            Authentication.shared.linkNewUser(withuid: authResult.user.uid, withData: newUser) {
                
                guard let window = self.view.window else { return }
                
                let vc = TabBarVC()
                vc.modalPresentationStyle = .fullScreen
                window.rootViewController = vc
                let options: UIView.AnimationOptions = .transitionCrossDissolve
                let duration: TimeInterval = 0.3
                UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: nil)
            }
            
            
            
//            guard let window = self.view.window else { return }
//            let vc = CommitmentsVC()
//            let navigationController = UINavigationController(rootViewController: vc)
//
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.shadowColor = nil
//
//            let navigationBar = navigationController.navigationBar
//            navigationBar.standardAppearance = appearance
//            navigationBar.scrollEdgeAppearance = appearance
//
//
//            window.rootViewController = navigationController
//            let options: UIView.AnimationOptions = .transitionCrossDissolve
//            let duration: TimeInterval = 0.3
//            UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: nil)
        }
        
        
    }
    
    // Copied from SignInVC
    private func showErrorBanner(withTitle title: String, subtitle: String? = nil) {
        showBanner(withStyle: .warning, title: title, subtitle: subtitle)
    }
    
    private func showBanner(withStyle style: BannerStyle, title: String, subtitle: String?) {
        guard bannerQueue.numberOfBanners == 0 else { return }
        let banner = FloatingNotificationBanner(title: title, subtitle: subtitle,
                                                titleFont: .systemFont(ofSize: 17, weight: .medium),
                                                subtitleFont: .systemFont(ofSize: 14, weight: .regular),
                                                style: style)
        banner.backgroundColor = .primary
        banner.show(bannerPosition: .top,
                    queue: bannerQueue,
                    edgeInsets: UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15),
                    cornerRadius: 10,
                    shadowColor: .primaryText,
                    shadowOpacity: 0.3,
                    shadowBlurRadius: 10)
    }
}
