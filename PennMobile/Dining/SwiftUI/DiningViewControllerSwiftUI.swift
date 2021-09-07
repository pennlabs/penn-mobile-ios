//
//  DiningTestView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

@available(iOS 14, *)
class DiningViewControllerSwiftUI: GenericViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingView = UIHostingController(rootView: DiningView())
        
        view.backgroundColor = .uiBackground
        self.screenName = "Dining SwiftUI"
        
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
        self.tabBarController?.title = "Dining"
    }
}
