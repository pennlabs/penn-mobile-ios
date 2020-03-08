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
    
    func getPacCode(callback: @escaping (_ result: Result<String, NetworkingError>) -> Void ) {
        makeAuthRequest(targetUrl: pacURL, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            
            guard let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                if let error = error as? NetworkingError {
                    callback(.failure(error))
                } else {
                    callback(.failure(.other))
                }
                return
            }
            
            do {
                let pacCode = try self.findPacCode(from: html as String)
                return callback(.success(pacCode))
            } catch {
                print("parsing error")
                return callback(.failure(.parsingError))
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
        
        
        if (identity.count == 6) {
            
            // PAC Code is stored in the 5th index of the array
            return identity[5]
        } else {
            throw NetworkingError.parsingError
        }
        
        
    }
    
    
    
}
