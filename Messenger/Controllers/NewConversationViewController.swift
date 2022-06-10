//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by ineta.magone on 08/06/2022.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {

    private let spinner = JGProgressHUD()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let noResultsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .white
        
        setupUiItems()
        // Putting searchBar on the top of the screen
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissConversation))
        // Invoke keyboard on searchBar
        searchBar.becomeFirstResponder()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "newConversationCell")
    }
    
    @objc private func dismissConversation() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

extension NewConversationViewController {
    
    func setupUiItems() {
        setupSpinner()
        setTableViewUi()
        setupSearchBar()
        setLabel()
    }
    
    func setupSpinner() {
        spinner.style = .dark
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
        tableView.isHidden = true
    }
    
    func setupSearchBar() {
        searchBar.placeholder = "Search for users..."
    }
    
    func setLabel() {
        view.addSubview(noResultsLabel)
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultsLabel.heightAnchor.constraint(equalToConstant: 60),
            noResultsLabel.widthAnchor.constraint(equalToConstant: 200),
        ])
        noResultsLabel.text = "No Search Results"
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .green
        noResultsLabel.font = .systemFont(ofSize: 21, weight: .medium)
        noResultsLabel.isHidden = true
    }
}
