//
//  CampusExpressNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 3/23/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup

class CampusExpressNetworkManager {
    static let instance = CampusExpressNetworkManager()
    private init() {}
}

extension CampusExpressNetworkManager: PennAuthRequestable {

    private var housingUrl: String {
        return "https://prod.campusexpress.upenn.edu/housing/view_assignment.jsp"
    }

    private var shibbolethUrl: String {
        return "https://prod.campusexpress.upenn.edu/Shibboleth.sso/SAML2/POST"
    }

    func updateHousingData(_ completion: ((_ success: Bool) -> Void)? = nil) {
        makeAuthRequest(targetUrl: housingUrl, shibbolethUrl: shibbolethUrl) { (data, _, _) in
            if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                if let doc = try? SwiftSoup.parse(html as String), let htmlStr = ((try? doc.body()?.html()) as String??), let html = htmlStr {
                    UserDBManager.shared.saveHousingData(html: html) { (result) in
                        completion?(result != nil)
                    }
                    return
                }
            }
            completion?(false)
        }
    }
}
