//
//  RegisterViewController.swift
//  Messenger
//
//  Created by ineta.magone on 08/06/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD()
    private let scrollView = UIScrollView()
    private let verticalStackView = UIStackView()
    private let horizontalStackView = UIStackView()
    private let imageView = UIImageView()
    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let registerButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeImage))
        imageView.addGestureRecognizer(gesture)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        setupUiItems()
    }
    
    @objc private func didTapChangeImage() {
        presentPhotoActionSheet()
    }
    
    @objc private func didTapRegister() {
        
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              
                !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertLoginError(message: "Please enter a valid information to create a new Account")
            return
        }
        
        spinner.show(in: view)
        // Firebase Register
        DatabaseManager.shared.userExists(with: email, completion: { [ weak self ] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                // user exists
                strongSelf.alertLoginError(message: "Account with specified email address already exists")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }
                
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                
                let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        // upload image
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData() else {
                                return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data,
                                                                   filename: fileName,
                                                                   completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Strorage Manager error: \(error)")
                            }
                        })
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    func alertLoginError(message: String) {
        let alert = UIAlertController(title: "Woops..", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

// Extension for setting up UI
private extension RegisterViewController {
    
    func setupUiItems() {
        title = "Register"
        view.backgroundColor = .white
        setupSpinner()
        setScrollView()
        setImageView()
        setVerticalStackView()
        setHorizontalStackView()
        setFirstName()
        setLastName()
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
        scrollView.addSubview(verticalStackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        //scrollView.backgroundColor = .cyan
        scrollView.clipsToBounds = true
        scrollView.isUserInteractionEnabled = true
    }
    
    func setImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
        ])
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.cornerRadius = 50
        imageView.isUserInteractionEnabled = true
    }
    
    func setVerticalStackView() {
        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(emailField)
        verticalStackView.addArrangedSubview(passwordField)
        verticalStackView.addArrangedSubview(registerButton)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            verticalStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ])
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        verticalStackView.alignment = .center
        verticalStackView.spacing = 5
    }
    
    func setHorizontalStackView() {
        horizontalStackView.addArrangedSubview(firstNameField)
        horizontalStackView.addArrangedSubview(lastNameField)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            horizontalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -70),
        ])
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 5
    }
    
    func setFirstName() {
        firstNameField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstNameField.heightAnchor.constraint(equalToConstant: 52),
        ])
        firstNameField.autocapitalizationType = .none
        firstNameField.autocorrectionType = .no
        firstNameField.returnKeyType = .continue
        firstNameField.layer.cornerRadius = 12
        firstNameField.layer.borderWidth = 1
        firstNameField.layer.borderColor = UIColor.black.cgColor
        firstNameField.placeholder = "Your First Name"
        firstNameField.backgroundColor = .lightGray
        firstNameField.textColor = .black
        firstNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        firstNameField.leftViewMode = .always
    }
    
    func setLastName() {
        lastNameField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lastNameField.heightAnchor.constraint(equalToConstant: 52),
            //lastNameField.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -70),
        ])
        lastNameField.autocapitalizationType = .none
        lastNameField.autocorrectionType = .no
        lastNameField.returnKeyType = .continue
        lastNameField.layer.cornerRadius = 12
        lastNameField.layer.borderWidth = 1
        lastNameField.layer.borderColor = UIColor.black.cgColor
        lastNameField.placeholder = "Your Last Name"
        lastNameField.backgroundColor = .lightGray
        lastNameField.backgroundColor = .lightGray
        lastNameField.textColor = .black
        lastNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        lastNameField.leftViewMode = .always
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
        passwordField.backgroundColor = .lightGray
        passwordField.textColor = .black
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        passwordField.leftViewMode = .always
        passwordField.isSecureTextEntry = true
    }
    
    func setLogInButton() {
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            registerButton.heightAnchor.constraint(equalToConstant: 52),
            registerButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -70),
        ])
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .purple
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        registerButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
        else if textField == lastNameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            didTapRegister()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Image", message: "Choose how to add an Image", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { [ weak self ] _ in self?.presentCamera()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose a Photo", style: .default, handler: {[ weak self ] _ in self?.presentPhotoPicker()
            
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
