//
//  NewConversationTableCell.swift
//  Messenger
//
//  Created by ineta.magone on 21/06/2022.
//

import UIKit
import SDWebImage

class NewConversationTableCell: UITableViewCell {

    static let reuseId = "NewConversationCell"

    private let userImageView = UIImageView()

    private let userNameLabel = UILabel()

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

    public func configure(with model: SearchResult) {
        userNameLabel.text = model.name

        let path = "images/\(model.email)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [ weak self ] result in
            switch result {
            case .success(let url):

                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }

            case .failure(let error):
                print("Failed to get image url: \(error)")
            }
        })
    }
}

extension NewConversationTableCell {
    
    func setupUiItems() {
        setupImageView()
        setupNameLabel()
    }
    
    func setupImageView() {
        contentView.addSubview(userImageView)
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            userImageView.heightAnchor.constraint(equalToConstant: 70),
            userImageView.widthAnchor.constraint(equalToConstant: 70),
        ])
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 35
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
    }
}
