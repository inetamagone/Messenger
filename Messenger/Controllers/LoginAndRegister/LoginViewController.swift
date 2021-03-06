//
//  LoginViewController.swift
//  Messenger
//
//  Created by ineta.magone on 08/06/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let logInButton = UIButton()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        logInButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        setupUiItems()
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc private func didTapLogin() {
        // Take away the keyboard
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertLoginError()
            return
        }
        
        spinner.show(in: view)
        // Firebase Log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [ weak self ] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard let result = authResult, error == nil else {
                print("Failed to sign in user: \(email)")
                return
            }
            
            let user = result.user
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                        let lastName = userData["last_name"] as? String else {
                            return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })

            UserDefaults.standard.set(email, forKey: "email")
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func alertLoginError() {
        let alert = UIAlertController(title: "Woops..", message: "Please enter a valid e-mail and password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

// Extension for setting up UI
private extension LoginViewController {
    
    func setupUiItems() {
        title = "Log in"
        view.backgroundColor = .white
        setupSpinner()
        setScrollView()
        setImageView()
        setStackView()
        setEmailField()
        setPasswordField()
        setLogInButton()
    }
    
    func setupSpinner() {
        spinner.style = .dark
    }
    
    func setScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        //scrollView.backgroundColor = .green
        scrollView.clipsToBounds = true
    }
    
    func setImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 130),
            imageView.widthAnchor.constraint(equalToConstant: 130),
        ])
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
    }
    
    func setStackView() {
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(logInButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
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
        emailField.backgroundColor = .lightGray
        emailField.textColor = .black
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
        passwordField.backgroundColor = .lightGray
        passwordField.textColor = .black
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

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapLogin()
        }
        return true
    }
}
