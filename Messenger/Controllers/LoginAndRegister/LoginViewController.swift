//
//  LoginViewController.swift
//  Messenger
//
//  Created by ineta.magone on 08/06/2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var imageView = UIImageView()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let logInButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        setupUiItems()
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

// Extension for setting up UI
private extension LoginViewController {
    
    func setupUiItems() {
        title = "Log in"
        view.backgroundColor = .white
        setScrollView()
        setStackView()
        setImageView()
        setEmailField()
        setPasswordField()
        setLogInButton()
    }
    
    func setScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        scrollView.backgroundColor = .lightGray
        scrollView.clipsToBounds = true
    }
    
    func setStackView() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(logInButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 30
    }
    
    func setImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 90),
            imageView.widthAnchor.constraint(equalToConstant: 90),
        ])
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
    }
    
    func setEmailField() {
        emailField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailField.heightAnchor.constraint(equalToConstant: 52),
            emailField.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -70),
        ])
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.returnKeyType = .continue
        emailField.layer.cornerRadius = 12
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.black.cgColor
        emailField.placeholder = "E-mail adress, ex. anthony@abc.com"
        emailField.backgroundColor = .white
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        emailField.leftViewMode = .always
    }
    
    func setPasswordField() {
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordField.heightAnchor.constraint(equalToConstant: 52),
            passwordField.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -70),
        ])
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.returnKeyType = .done
        passwordField.layer.cornerRadius = 12
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.black.cgColor
        passwordField.placeholder = "Password..."
        passwordField.backgroundColor = .white
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        passwordField.leftViewMode = .always
        passwordField.isSecureTextEntry = true
    }
    
    func setLogInButton() {
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logInButton.heightAnchor.constraint(equalToConstant: 52),
            logInButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -70),
        ])
        logInButton.setTitle("Log In", for: .normal)
        logInButton.backgroundColor = .link
        logInButton.setTitleColor(.white, for: .normal)
        logInButton.layer.cornerRadius = 12
        logInButton.layer.masksToBounds = true
        logInButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    }
}
