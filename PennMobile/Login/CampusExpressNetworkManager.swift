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
    
    fileprivate func parseDiningBalances(from html: String) throws -> DiningBalance? {
        let doc: Document = try SwiftSoup.parse(html)
        guard let element = try doc.getElementsByClass("PAD_subpage").first() else {
            throw NetworkingError.parsingError
        }
        let noPlan = try element.getElementsByClass("subTEXT").first()
        
        if try noPlan?.text() == "You are not currently signed up for a Dining Plan." {
            UserDefaults.standard.set(hasDiningPlan: false)
            return nil
        }
        UserDefaults.standard.set(hasDiningPlan: true)
        let subElements = try doc.select("li")
        
        let visitsArray = try subElements.get(0).text().split(separator: " ")
        let guestVisitsArray = try subElements.get(1).text().split(separator: " ")
        let addOnVisitsArray = try subElements.get(2).text().split(separator: " ")
        let diningDollarsArray = try subElements.get(3).text().split(separator: " ")
        if (visitsArray.count < 2 || guestVisitsArray.count < 3 || addOnVisitsArray.count < 3 || diningDollarsArray.count < 3) {
            throw NetworkingError.parsingError
        }
        let visits = Int (visitsArray[1])
        let guestVisits = Int (guestVisitsArray[2])
        let addOnVisits = Int (addOnVisitsArray[2])
        let diningDollarsStr = String (diningDollarsArray[2]).dropFirst()
        let diningDollars = Float(diningDollarsStr)
        return DiningBalance(diningDollars: diningDollars!, visits: visits! + addOnVisits!, guestVisits: guestVisits!, lastUpdated: Date())
    }
}

