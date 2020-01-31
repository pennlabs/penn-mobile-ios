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

protocol TwoFactorEnableDelegate {
    func handleEnable()
    func handleDismiss()
    func shouldWait() -> Bool
}

extension TwoFactorEnableDelegate {
    func shouldWait() -> Bool {
        return true
    }
}

@available(iOS 13, *)
class TwoFactorEnableController: UIViewController, IndicatorEnabled, URLOpenable {
    
    private var cancellable: Any?
    
    public var delegate: TwoFactorEnableDelegate!
    
    let shouldRequestLogin = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prompt = """
        Enable this feature to remain logged in to Penn Mobile. Otherwise, you may have to log in again every 2-3 weeks. You can change your decision later in the More tab.
        
        Penn Mobile will become a Two-Step PennKey verification app. You can use it to generate one-time codes to log in to Penn resources.
        
        The TOTP token we use to generate codes will never leave this device. It will be stored in your iPhone's secure enclave.
        """
        
        let delegate = PrivacyPermissionDelegate()
        self.cancellable = delegate.objectDidChange.sink { (delegate) in
            if let decision = delegate.userDecision {
                switch decision {
                case .affirmative:
                    UserDefaults.standard.set(true, forKey: "TOTPEnabled")
                    TOTPFetcher.instance.fetchAndSaveTOTPSecret()
                    if self.delegate.shouldWait() {
                        DispatchQueue.main.async {
                            self.showActivity()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.hideActivity()
                                self.delegate.handleEnable()
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } else {
                        self.delegate.handleEnable()
                        self.dismiss(animated: true, completion: nil)
                    }
                case .negative:
                    UserDefaults.standard.set(false, forKey: "TOTPEnabled")
                    delegate.handleDismiss()
                    self.dismiss(animated: true, completion: nil)
                case .moreInfo: self.open(scheme: "https://www.isc.upenn.edu/how-to/two-step-faq")
                }
            }
        }
        
        let childView = UIHostingController(rootView: PermissionView(delegate: delegate, title: "Two-Step Verification", privacyString: prompt, affirmativeString: "Enable Two-Step Verification", negativeString: "Don't enable", moreInfoString: "Learn more"))
        
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
