//
//  CoursePrivacyController.swift
//  PennMobile
//
//  Created by Josh Doman on 1/1/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
class CoursePrivacyController: UIViewController, IndicatorEnabled, URLOpenable {
    
    private var cancellable: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prompt = """
        Help us improve our course recommendation algorithms by sharing anonymized course enrollments with Penn Labs. You can change your decision later.

        No course enrollments are ever associated with your name, PennKey, or email.

        This allows Penn Labs to recommend courses to other students based on what you’ve taken, improving student life for everyone at Penn. That’s what we do 💖
        """
        
        let delegate = PrivacyPermissionDelegate()
        self.cancellable = delegate.objectDidChange.sink { (delegate) in
            if let decision = delegate.userDecision {
                switch decision {
                case .affirmative:
                    UserDefaults.standard.setLastDidAskPermission(for: .anonymizedCourseSchedule)
                    UserDefaults.standard.set(.anonymizedCourseSchedule, to: true)
                    UserDBManager.shared.saveUserPrivacySettings()
                    self.fetchAndSaveCourses()
                case .negative:
                    UserDefaults.standard.setLastDidAskPermission(for: .anonymizedCourseSchedule)
                    self.declinePermission()
                    self.dismiss(animated: true, completion: nil)
                case .moreInfo: self.open(scheme: "https://pennlabs.org")
                }
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
    fileprivate func fetchAndSaveCourses(shouldRequestLoginOnFail: Bool = true) {
        showActivity()
        PennInTouchNetworkManager.instance.getCourses { (result) in
            DispatchQueue.main.async {
                if let courses = try? result.get()  {
                    // Save courses anonymously on database
                    UserDBManager.shared.saveCoursesAnonymously(courses) { (success) in
                        DispatchQueue.main.async {
                            UserDefaults.standard.saveCourses(courses)
                            self.hideActivity()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                } else if shouldRequestLoginOnFail {
                    // Failed to retrieve courses. Request user to login in case failure was due to authentication.
                    self.hideActivity()
                    let llc = LabsLoginController(fetchAllInfo: false) { (success) in
                        if success {
                            // Do NOT request login a second time
                            self.fetchAndSaveCourses(shouldRequestLoginOnFail: false)
                        } else {
                            self.hideActivity()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    let nvc = UINavigationController(rootViewController: llc)
                    self.present(nvc, animated: true, completion: nil)
                } else {
                    self.hideActivity()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    fileprivate func declinePermission() {
        UserDefaults.standard.set(.anonymizedCourseSchedule, to: false)
        UserDBManager.shared.saveUserPrivacySettings()
    }
}
