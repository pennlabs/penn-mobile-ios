//
//  DiningStatisticsViewController.swift
//  PennMobile
//
//  Created by Elizabeth Powell on 2/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
class DiningStatisticsViewController: UIViewController {
    
    private var cancellable: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = PrivacyPermissionDelegate()
        self.cancellable = delegate.objectDidChange.sink { (delegate) in
            if let decision = delegate.userDecision {
                switch decision {
                case .affirmative:
                    UserDefaults.standard.setLastDidAskPermission(for: .anonymizedCourseSchedule)
                    UserDefaults.standard.set(.anonymizedCourseSchedule, to: true)
                    UserDBManager.shared.saveUserPrivacySettings()
                    //self.fetchAndSaveCourses()
                case .negative:
                    UserDefaults.standard.setLastDidAskPermission(for: .anonymizedCourseSchedule)
                    //self.declinePermission()
                    self.dismiss(animated: true, completion: nil)
                case .moreInfo:
                    print("nothing")
                }
            }
        }
        
        let cards: [DiningStatisticsCard] = [
            DiningStatisticsCard(Text("Hello World")),
            DiningStatisticsCard(Group{ Text("Hello darkness") })
        ]
        
        let childView = UIHostingController(rootView: DiningStatisticsView(cards: cards))
        
        addChild(childView)
        childView.view.frame = view.bounds
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
}
