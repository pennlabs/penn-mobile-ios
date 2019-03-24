//
//  CampusExpressNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 3/23/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class CampusExpressNetworkManager {
    static let instance = CampusExpressNetworkManager()
    private init() {}
}

extension CampusExpressNetworkManager: PennAuthRequestable {
    
    private var housingUrl: String {
        return "https://prod.campusexpress.upenn.edu/housing/"
    }
    
    private var diningUrl: String {
        return "https://prod.campusexpress.upenn.edu/dining/balance.jsp"
    }
    
    private var shibbolethUrl: String {
        return "https://prod.campusexpress.upenn.edu/Shibboleth.sso/SAML2/POST"
    }
    
    func getHousingData() {
        makeAuthRequest(targetUrl: housingUrl, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                print(html)
            } else {
                print("Something went wrong")
            }
        }
    }
    
    func getDiningData() {
        makeAuthRequest(targetUrl: diningUrl, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                print(html)
            } else {
                print("Something went wrong")
            }
        }
    }
}