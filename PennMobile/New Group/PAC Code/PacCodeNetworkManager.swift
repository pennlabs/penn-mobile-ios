//
//  PacCodeNetworkManager.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 1/3/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftSoup

class PacCodeNetworkManager {
    static let instance = PacCodeNetworkManager()
    private init() {}
}

extension PacCodeNetworkManager: PennAuthRequestable {

    private var pacURL: String {
        return "https://penncard.apps.upenn.edu/penncard/jsp/fast2.do?fastStart=pacExpress"
    }
    
    private var shibbolethUrl: String {
        return "https://penncard.apps.upenn.edu/penncard/jsp/fast2.do/Shibboleth.sso/SAML2/POST"
    }
    
    func getPacCode(callback: @escaping ((_ code: String?) -> Void)) {
        makeAuthRequest(targetUrl: pacURL, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        do {
                            let pacCode = try self.findPacCode(from: html)
                            return callback(pacCode)
                        } catch {
                            return callback(nil)
                        }
                    }
                }
            } else {
                return callback(nil)
            }
        }
    }
    
    private func findPacCode(from html: String) throws -> String {
        let doc: Document = try SwiftSoup.parse(html)
        guard let element: Element = try doc.getElementsByClass("msgbody").first() else {
            throw NetworkingError.parsingError
        }
        
        // Stores ["Name", name in caps, "PennId", Penn ID, "Current PAC", PAC Code]
        var identity = [String]()
        
        do {
            for row in try element.select("tr") {
                for col in try row.select("td") {
                    let colContent = try col.text()
                    identity.append(colContent)
                }
            }
        } catch {
            throw NetworkingError.parsingError
        }
        
        // PAC Code is stored in the 5th index of the array
        return identity[5]
    }
    
    
    
}
