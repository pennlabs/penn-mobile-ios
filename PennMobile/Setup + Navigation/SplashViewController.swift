//
//  SplashViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/25/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import FirebaseCore

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        var imageView: UIImageView
        imageView = UIImageView()
        imageView.image = UIImage(named: "LaunchIcon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: view.frame.width/5*2).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.frame.width/5*2).isActive = true
    }
}
