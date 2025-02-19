//
//  GSRViewControllerSwiftUI.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

// Note, this is for compatability with existing codebase. See ControllerModel.swift
class GSRViewControllerSwiftUI: GenericViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let hostingView = UIHostingController(rootView: GSRCentralView())

        view.backgroundColor = .uiBackground
        self.screenName = "GSR"
        self.title = "GSR Booking"

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
        self.tabBarController?.title = "GSR Booking"
    }
}
