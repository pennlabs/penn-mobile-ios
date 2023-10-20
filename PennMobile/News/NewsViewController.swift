//
//  NewsViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 5/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit
import WebKit

class NewsViewController: GenericViewController {

    private let urlArray = ["http://thedp.com/", "http://thedp.com/blog/under-the-button/", "http://34st.com/"]

    private var webview: WKWebView!
    private var newsSwitcher: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News"

        setupSegmentedController()
        setupWebview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "News"
    }

    func setupSegmentedController() {
        newsSwitcher = UISegmentedControl(items: ["theDP", "UTB", "34th Street"])
        newsSwitcher.selectedSegmentIndex = 0
        newsSwitcher.isUserInteractionEnabled = true
        newsSwitcher.addTarget(self, action: #selector(switchNewsSource(_:)), for: .valueChanged)

        view.addSubview(newsSwitcher)
        newsSwitcher.translatesAutoresizingMaskIntoConstraints = false
        newsSwitcher.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        newsSwitcher.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }

    private func setupWebview() {
        webview = WKWebView()

        view.addSubview(webview)
        webview.translatesAutoresizingMaskIntoConstraints = false

        webview.topAnchor.constraint(equalToSystemSpacingBelow: newsSwitcher.bottomAnchor, multiplier: 1.0).isActive = true
        webview.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        webview.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        webview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        webview.load(URLRequest(url: URL(string: urlArray[0])!))
    }

    @objc internal func switchNewsSource(_ segment: UISegmentedControl) {
        webview.load(URLRequest(url: URL(string: urlArray[segment.selectedSegmentIndex])!))
    }
}
