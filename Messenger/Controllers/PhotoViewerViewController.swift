//
//  PhotoViewerViewController.swift
//  Messenger
//
//  Created by ineta.magone on 08/06/2022.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {

    private let url: URL

    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        imageView.sd_setImage(with: url, completed: nil)
    }
}

extension PhotoViewerViewController {
     
    func setupUI() {
        title = "Photo"
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
    }
}
