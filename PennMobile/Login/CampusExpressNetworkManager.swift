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
    
    func getHousingData() {
        makeAuthRequest(targetUrl: housingUrl, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                print(html)
            } else {
                print("Something went wrong")
            }
        }
    }
    
    func getDiningData(callback: @escaping ((_ diningBalances: DiningBalance?) -> Void)) {
        makeAuthRequest(targetUrl: diningUrl, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                do {
                    let diningBalances = try self.parseDiningBalances(from: html as String)
                    callback(diningBalances)
                    return
                } catch {}
            } else {
                print("Something went wrong")
            }
        }
    }
}

// MARK: - Dining Dollars Parsing
extension CampusExpressNetworkManager {
    
    fileprivate func parseDiningBalances(from html: String) throws -> DiningBalance {
        let doc: Document = try SwiftSoup.parse(html)
        guard let element = try doc.getElementsByClass("PAD_subpage").first() else {
            throw NetworkingError.parsingError
        }
        let plan = try element.select("a")
        let noPlan = try element.getElementsByClass("subTEXT").first()
        let diningPlan = try plan.text()
        
        if try noPlan?.text() == "You are not currently signed up for a Dining Plan." {
            return DiningBalance(hasDiningPlan: false, balancesAsOf: nil, planName: nil, diningDollars: nil, visits: nil, addOnVisits: nil, guestVisits: nil)
        }
        
        let balancesAsOf = try doc.select("h4").first()?.text()
        let subElements = try doc.select("li")
        let visits = Int (try subElements.get(0).text().split(separator: " ")[1])
        let guestVisits = Int (try subElements.get(1).text().split(separator: " ")[2])
        let addOnVisits = Int (try subElements.get(2).text().split(separator: " ")[2])
        let diningDollars = String (try subElements.get(3).text().split(separator: " ")[2])
        return DiningBalance(hasDiningPlan: true, balancesAsOf: balancesAsOf,  planName: diningPlan, diningDollars: diningDollars, visits: visits, addOnVisits: addOnVisits, guestVisits: guestVisits)
    }
}

