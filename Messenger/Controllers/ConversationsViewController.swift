//
//  ViewController.swift
//  Messenger
//
//  Created by ineta.magone on 08/06/2022.
//

import UIKit
import FirebaseAuth
import SwiftUI
import JGProgressHUD

class ConversationsViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    private let tableView = UITableView()
    private let noConversationsLabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .red
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "conversationCell")
        setupUiItems()
        setupTableView()
        getConversations()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func getConversations() {
        tableView.isHidden = false
    }


}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath)
        cell.textLabel?.text = "Hello World"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController()
        vc.title = "Jenny Joe"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ConversationsViewController {
    
    func setupUiItems() {
        setTableViewUi()
        setLabel()
    }
    
    func setTableViewUi() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        // Don't show if no conversations
        tableView.isHidden = true
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

