//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by ineta.magone on 08/06/2022.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var completion: ((SearchResult) -> (Void))?

    private let spinner = JGProgressHUD()
    
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    
    private var hasFetched = false
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let noResultsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        tableView.register(NewConversationTableCell.self, forCellReuseIdentifier: NewConversationTableCell.reuseId)
    }
    
    @objc private func dismissConversation() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let sarchQuery = searchBar.text, !sarchQuery.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        results.removeAll()
        spinner.show(in: view)
        
        self.searchUsers(query: sarchQuery)
    }
    
    func searchUsers(query: String) {
        // check if array has Firebase results
        if hasFetched {
            // if yes - filter
            filterUsers(with: query)
        } else {
            // if not - fetch then filter
            DatabaseManager.shared.getAllUsers(completion: { [ weak self ] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    
    func filterUsers(with term: String) {
        // update UI
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }

        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)

        self.spinner.dismiss()

        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }

            guard let name = $0["name"]?.lowercased() else {
                return false
            }

            return name.hasPrefix(term.lowercased())
        }).compactMap({

            guard let email = $0["email"],
                let name = $0["name"] else {
                return nil
            }

            return SearchResult(name: name, email: email)
        })

        self.results = results

        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationTableCell.reuseId, for: indexPath) as! NewConversationTableCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
        let targetUserData = results[indexPath.row]
        dismiss(animated: true, completion: { [ weak self ] in
            self?.completion?(targetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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
