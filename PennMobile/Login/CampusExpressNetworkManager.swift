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
    
    func getDiningData() {
        makeAuthRequest(targetUrl: diningUrl, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                do {
                    try self.parseDiningDollars(from: html as String)
                } catch {}
            } else {
                print("Something went wrong")
            }
        }
    }
}

// MARK: - Dining Dollars Parsing
extension CampusExpressNetworkManager {
    
    fileprivate func parseDiningDollars(from html: String) throws -> DiningBalances {
        let doc: Document = try SwiftSoup.parse(html)
        guard let element = try doc.getElementsByClass("PAD_subpage").first() else {
            throw NetworkingError.parsingError
        }
        let plan = try element.select("a")
        let diningPlan = try plan.text()
        print(diningPlan)
        
        if plan == nil {
            return DiningBalances(hasDiningPlan: true, planName: nil, diningDollars: nil, visits: nil, guestVisits: nil)
        }
        
        let subElements = try doc.select("li")
        let visits = Int (try subElements.get(0).text().split(separator: " ")[1])
        print(visits!)
        let guestVisits = Int (try subElements.get(1).text().split(separator: " ")[2])
        print(guestVisits!)
        let addOnVisits = Int (try subElements.get(2).text().split(separator: " ")[1])
        print(visits!)
//        let totalVisits = visits! + addOnVisits!
//        print(totalVisits)
        let diningDollars = String (try subElements.get(3).text().split(separator: " ")[2])
        print(diningDollars)
        return DiningBalances(hasDiningPlan: true, planName: diningPlan, diningDollars: diningDollars, visits: visits, guestVisits: guestVisits)
    }
    
    fileprivate func parseDegrees(from html: String) throws -> Set<Degree> {
        let doc: Document = try SwiftSoup.parse(html)
        guard let element: Element = try doc.getElementsByClass("data").first() else {
            throw NetworkingError.parsingError
        }
        let subElements = try element.select("li")
        var degrees = Set<Degree>()
        for element in subElements {
            let text = try element.text()
            guard let schoolStr = text.getMatches(for: "Division: (.*?)\\) ").first,
                let degreeStr = text.getMatches(for: "Degree: (.*?)\\)").first,
                let expectedGradTerm = text.getMatches(for: "Expected graduation term: (.*?\\d) ").first else {
                    throw NetworkingError.parsingError
            }
            var majors = Set<Major>()
            if let majorText = text.getMatches(for: "Major\\(s\\):(.*?)Expected graduation term").first?.split(separator: ":").first {
                let majorStr = String(majorText).getMatches(for: "\\d\\. (.*?)\\)")
                for str in majorStr {
                    if let nameCode = try? splitNameCode(str: str) {
                        majors.insert(Major(name: nameCode.name, code: nameCode.code))
                    }
                }
            }
            let schoolNameCode = try splitNameCode(str: schoolStr)
            let degreeNameCode = try splitNameCode(str: degreeStr)
            let degree = Degree(schoolName: schoolNameCode.name, schoolCode: schoolNameCode.code, degreeName: degreeNameCode.name, degreeCode: degreeNameCode.code, majors: majors, expectedGradTerm: expectedGradTerm)
            degrees.insert(degree)
        }
        return degrees
    }
    
    private func splitNameCode(str: String) throws -> (name: String, code: String) {
        let split = str.split(separator: "(")
        if split.count != 2 {
            throw NetworkingError.parsingError
        }
        let name = String(split[0].dropLast())
        let code = String(split[1])
        return (name, code)
    }
}

