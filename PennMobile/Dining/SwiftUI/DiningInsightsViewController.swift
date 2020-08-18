//
//  DiningInsightsViewController.swift
//  PennMobile
//
//  Created by Elizabeth Powell on 2/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
class DiningInsightsViewController: UIViewController, ShowsAlert {
    
    private var cancellable: Any?
    
    private var hostingView: UIHostingController<DiningInsightsView>!
    
    @State var int = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if Account.isLoggedIn {
            hostingView = UIHostingController(rootView: DiningInsightsView(pickerIndex: $int))
            addChild(hostingView)
            view.addSubview(hostingView.view)
            hostingView.didMove(toParent: self)
            hostingView.view.frame = view.bounds
        } else {
            // Remove view if user is not logged in
            if let hostingView = hostingView {
                hostingView.view.removeFromSuperview()
                view.layoutIfNeeded()
            }

            showAlert(withMsg: "Please login to use this feature", completion: nil)
        }
    }
}
