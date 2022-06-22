//
//  ProfileTableViewCell.swift
//  Messenger
//
//  Created by ineta.magone on 21/06/2022.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    static let reuseId = "ProfileTableViewCell"

    public func setUp(with viewModel: ProfileViewModel) {
        self.textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        }
    }
}
