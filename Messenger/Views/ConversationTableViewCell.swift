//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by ineta.magone on 14/06/2022.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let reuseId = "conversationCell"
    
    private let userImageView = UIImageView()
    private let userNameLabel = UILabel()
    private let userMessageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUiItems()
    }
    
    public func configure(with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    }
    
}

extension ConversationTableViewCell {
    
    func setupUiItems() {
        //contentView.backgroundColor = .green
        setupImage()
        setupNameLabel()
        setupMessageLabel()
    }
    
    func setupImage() {
        contentView.addSubview(userImageView)
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            userImageView.heightAnchor.constraint(equalToConstant: 100),
            userImageView.widthAnchor.constraint(equalToConstant: 100),
        ])
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 50
        userImageView.layer.masksToBounds = true
    }
    
    func setupNameLabel() {
        contentView.addSubview(userNameLabel)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 124),
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userNameLabel.heightAnchor.constraint(equalToConstant: 50),
            userNameLabel.widthAnchor.constraint(equalToConstant: 150),
        ])
        userNameLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        //userNameLabel.text = "Test username"
        //userNameLabel.backgroundColor = .yellow
    }
    
    func setupMessageLabel() {
        contentView.addSubview(userMessageLabel)
        userMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userMessageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 124),
            userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
            userMessageLabel.heightAnchor.constraint(equalToConstant: 50),
            userMessageLabel.widthAnchor.constraint(equalToConstant: 150),
        ])
        userMessageLabel.font = .systemFont(ofSize: 19, weight: .regular)
        userMessageLabel.numberOfLines = 0
        //userMessageLabel.backgroundColor = .gray
    }
    
}
