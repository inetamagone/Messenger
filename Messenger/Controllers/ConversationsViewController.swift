//
//  ViewController.swift
//  Messenger
//
//  Created by ineta.magone on 08/06/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {

    private let spinner = JGProgressHUD()
    
    private var conversations = [Conversation]()
    
    private let myTableView = UITableView()
    private let noConversationsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .red
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        setupUiItems()
        myTableView.delegate = self
        myTableView.dataSource = self
        startListeningForConversations()
    }
    
    // Update the tableView when new conversation added
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("Starting conversation fetch")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [ weak self ] result in
            switch result {
            case .success(let conversations):
                print("Success for conversation models")
                guard !conversations.isEmpty else {
                    print("Conversations are empty")
                    return
                }
                //print("conversations: \(conversations)")
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.myTableView.reloadData()
                }
            case .failure(let error):
                print("Failed to get conversations: \(error)")
            }
        })
    }
    
    @objc private func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = { [ weak self ] result in
            print("\(result)")
            
            self?.createNewConversation(result: result)
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"],
              let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func getConversations() {
        myTableView.isHidden = false
    }

}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("conversations.count: \(conversations.count)")
        if conversations.count == 0 {
            myTableView.isHidden = true
            noConversationsLabel.isHidden = false
        } else {
            myTableView.isHidden = false
            noConversationsLabel.isHidden = true
        }
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        guard let cell = myTableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.reuseId, for: indexPath) as? ConversationTableViewCell else {return .init()}
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        let vc = ChatViewController(with: model.otherUserEmail)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension ConversationsViewController {
    
    func setupUiItems() {
        setupSpinner()
        setTableViewUi()
        setLabel()
    }
    
    func setupSpinner() {
        spinner.style = .dark
    }
    
    func setTableViewUi() {
        view.addSubview(myTableView)
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            myTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            myTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        // Don't show if no conversations
        myTableView.isHidden = true
        myTableView.backgroundColor = .purple
        myTableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.reuseId)
    }
    
    func setLabel() {
        view.addSubview(noConversationsLabel)
        noConversationsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noConversationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noConversationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noConversationsLabel.heightAnchor.constraint(equalToConstant: 60),
            noConversationsLabel.widthAnchor.constraint(equalToConstant: 200),
        ])
        noConversationsLabel.text = "No conversations yet"
        noConversationsLabel.textAlignment = .center
        noConversationsLabel.textColor = .gray
        noConversationsLabel.font = .systemFont(ofSize: 21, weight: .medium)
        noConversationsLabel.isHidden = true
    }
}

