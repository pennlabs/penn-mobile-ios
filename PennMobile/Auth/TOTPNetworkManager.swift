//
//  TOTPNetworkManager.swift
//  PennMobile
//
//  Created by Henrique Lorente on 11/17/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import SwiftSoup

class TOTPNetworkManager {
    static let instance = TOTPNetworkManager()
    private init() {}
}

extension TOTPNetworkManager: PennAuthRequestable {

    private var targetUrl: String {
        return "https://twostep.apps.upenn.edu/twoFactor/twoFactorUi/app/UiMain.index"
    }

    private var shibbolethUrl: String {
        return "https://twostep.apps.upenn.edu/twoFactor/twoFactorUi/Shibboleth.sso/SAML2/POST"
    }

    func login(_ completion: @escaping () -> Void) {
        makeAuthRequest(targetUrl: targetUrl, shibbolethUrl: shibbolethUrl) { (_, _, _) in
            completion()
        }
    }
}
