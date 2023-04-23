//
//  NotificationsViewControllerSwiftUI.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

class NotificationsViewControllerSwiftUI: GenericViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let hostingView = UIHostingController(rootView: NotificationsView())

        view.backgroundColor = .uiBackground
        self.screenName = "Notifications SwiftUI"

        addChild(hostingView)
        view.addSubview(hostingView.view)
        hostingView.didMove(toParent: self)

        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
        hostingView.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        hostingView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        hostingView.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        hostingView.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "Notifications"
    }
}
