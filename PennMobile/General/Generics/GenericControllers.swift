//
//  GenericViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit
import SwiftUI

class GenericTableViewController: UITableViewController, Trackable {

    var navigationVC: HomeNavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationVC?.navigationBar.tintColor = UIColor.navigation
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationVC = self.navigationController as? HomeNavigationController
        navigationVC?.navigationBar.tintColor = UIColor.navigation

        if trackScreen {
            trackScreen(screenName)
        }

        setupNavBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationVC?.hideBar(animated: false)
    }

    func setupNavBar() {
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }

    var screenName: String?

    var trackScreen: Bool {
        #if DEBUG
            return false
        #else
            return true
        #endif
    }
}

class GenericViewController: UIViewController, Trackable {

    var navigationVC: HomeNavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .uiBackground
        navigationVC = navigationController as? HomeNavigationController
        navigationVC?.navigationBar.tintColor = UIColor.navigation
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationVC?.navigationBar.tintColor = UIColor.navigation

        if trackScreen {
            trackScreen(screenName ?? title)
        }

        setupNavBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationVC?.hideBar(animated: false)
    }

    func setupNavBar() {
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }

    var screenName: String?
    var trackScreen: Bool {
        #if DEBUG
            return false
        #else
            return true
        #endif
    }

    func removeMenuButton() {
        self.navigationItem.leftBarButtonItem = nil
    }
}

/// ``GenericViewController`` instance that uses a SwiftUI view for its content.
///
/// To use this view controller, subclass and override ``content`` and ``tabTitle``.
class GenericSwiftUIViewController<Content: View>: GenericViewController {
    /// Content of the view controller.
    open var content: Content {
        fatalError("makeSwiftUIView() not implemented")
    }

    /// Title of the view controller, displayed in the tab bar and navigation bar.
    open var tabTitle: String? {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let hostingController = UIHostingController(rootView: content)

        view.backgroundColor = .uiBackground
        title = tabTitle
        screenName = tabTitle

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.title = tabTitle
    }
}
