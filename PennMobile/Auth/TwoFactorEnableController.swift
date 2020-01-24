//
//  TwoFactorEnableController.swift
//  PennMobile
//
//  Created by Henrique Lorente on 1/24/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
class TwoFactorEnableController: UIViewController, IndicatorEnabled, URLOpenable {
    
    private var cancellable: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prompt = """
        By enabling this feature, you will stay logged in to Penn Mobile. Otherwise, you will be logged out every 2-3 weeks.
        
        This will add Penn Mobile as a Two-Step PennKey Verification app. You can use it to generate a one-time code to log in to Penn resources.

        Security is of upmost importance to us, and your login credentials will never leave this device.
        """
        
        let delegate = PrivacyPermissionDelegate()
        self.cancellable = delegate.objectDidChange.sink { (delegate) in
            if let decision = delegate.userDecision {
                switch decision {
                case .affirmative:
                    UserDefaults.standard.set(true, forKey: "TOTPEnabled")
                    TOTPFetcher.instance.fetchAndSaveTOTPSecret()
                    DispatchQueue.main.async {
                        self.showActivity()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.hideActivity()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                case .negative:
                    UserDefaults.standard.set(false, forKey: "TOTPEnabled")
                    self.dismiss(animated: true, completion: nil)
                case .moreInfo: self.open(scheme: "https://pennlabs.org")
                }
            }
        }
        
        let childView = UIHostingController(rootView: PermissionView(delegate: delegate, title: "Two-Step Verification", privacyString: prompt, affirmativeString: "Enable Two-Step Verification", negativeString: "Don't enable", moreInfoString: "More about Penn Labs"))
        
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
