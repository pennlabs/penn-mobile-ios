//
//  FitnessViewControllerSwiftUI.swift
//  PennMobile
//
//  Created by Jordan H on 4/7/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

class FitnessViewControllerSwiftUI: GenericViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let hostingView = UIHostingController(rootView: FitnessView())

        view.backgroundColor = .uiBackground
        self.screenName = "Fitness"
        self.title = "Fitness"

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
        self.tabBarController?.title = "Fitness"
    }
}
