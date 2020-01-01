//
//  CoursePrivacyController.swift
//  PennMobile
//
//  Created by Josh Doman on 1/1/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

@available(iOS 13, *)
class CoursePrivacyController: UIViewController, IndicatorEnabled, URLOpenable {
    
    private var cancellable: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prompt = """
        Help us improve our course recommendation algorithms by sharing  anonymized course enrollments with Penn Labs. You can change your decision later.

        No course enrollments are ever associated with your name, PennKey, or email.

        This allows Penn Labs to recommend courses to other students based on what you’ve taken, improving student life for everyone at Penn. That’s what we do 💖
        """
        
        let delegate = PrivacyPermissionDelegate()
        self.cancellable = delegate.objectDidChange.sink { (delegate) in
            if let decision = delegate.userDecision {
                switch decision {
                case .affirmative: self.fetchAndSaveCourses()
                case .negative: print("NO CONSENT GIVEN")
                case .moreInfo: self.open(scheme: "https://pennlabs.org")
                case .close: self.dismiss(animated: true, completion: nil)
                }
                //vc.dismiss(animated: true, completion: nil)
            }
        }
        
        let childView = UIHostingController(rootView: PermissionView(delegate: delegate, title: "Share Courses", privacyString: prompt, affirmativeString: "Share Courses with Penn Labs", negativeString: "Don't Share", moreInfoString: "More about Penn Labs"))
        
        addChild(childView)
        childView.view.frame = view.bounds
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Networking
@available(iOS 13, *)
extension CoursePrivacyController {
    fileprivate func fetchAndSaveCourses() {
        showActivity()
        PennInTouchNetworkManager.instance.getCourses { (courses) in
            DispatchQueue.main.async {
                print(courses)
                self.hideActivity()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
