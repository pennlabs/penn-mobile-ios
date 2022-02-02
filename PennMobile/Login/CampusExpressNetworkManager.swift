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

    private var diningUrl: String {
        return "https://prod.campusexpress.upenn.edu/dining/balance.jsp"
    }

    private var shibbolethUrl: String {
        return "https://prod.campusexpress.upenn.edu/Shibboleth.sso/SAML2/POST"
    }

    func updateHousingData(_ completion: ((_ success: Bool) -> Void)? = nil) {
        makeAuthRequest(targetUrl: housingUrl, shibbolethUrl: shibbolethUrl) { (data, response, error) in
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

    func getDiningBalanceHTML(callback: @escaping (_ html: String?, _ error: Error?) -> Void) {
        makeAuthRequest(targetUrl: diningUrl, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                if let doc = try? SwiftSoup.parse(html as String), let htmlStr = ((try? doc.body()?.html()) as String??) {
                    callback(htmlStr, error)
                }
            } else {
                callback(nil, error)
            }
        }
    }

    func getDiningBalance(_ completion: @escaping (_ diningBalance: DiningBalance?) -> Void) {
        makeAuthRequest(targetUrl: diningUrl, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let data = data, let html = String(data: data, encoding: .utf8) {
                if let doc = try? SwiftSoup.parse(html), let elementsText = try? doc.getElementsByClass("positive-value").text().split(separator: " "), elementsText.count >= 4 {
                    var diningBalance = elementsText[0]
                    diningBalance.removeFirst()

                    completion(DiningBalance(diningDollars: Float(diningBalance) ?? 0, visits: Int(elementsText[1]) ?? 0, guestVisits: Int(elementsText[2]) ?? 0, lastUpdated: Date()))
                } else {
                    completion(DiningBalance(diningDollars: 0, visits: 0, guestVisits: 0, lastUpdated: Date()))
                }
            } else {
                completion(DiningBalance(diningDollars: 0, visits: 0, guestVisits: 0, lastUpdated: Date()))
            }
        }
    }
}
