//
//  ProfileViewController.swift
//  Messenger
//
//  Created by ineta.magone on 08/06/2022.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    private let tableView = UITableView()
    private var headerView: UIView!
    private var imageView: UIImageView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = createTableHeader()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/"+filename
        imageView = setImageUI()
        headerView = setHeaderUI()
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadUrl(for: path, completion: { [ weak self ] result in
            
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: (self?.imageView)!, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        return headerView
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [ weak self ] _ in
            guard let strongSelf = self else {
                return
            }
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("Failed to Log Out")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
        
    }
}

extension ProfileViewController {
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func setHeaderUI() -> UIView {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 300))
        headerView.backgroundColor = .white
        return headerView
    }
    
    func setImageUI() -> UIImageView {
        imageView = UIImageView(frame: CGRect(x: (UIScreen.main.bounds.width-150) / 2, y: 75, width: 150, height: 150))
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 75
        return imageView
    }
    
}
