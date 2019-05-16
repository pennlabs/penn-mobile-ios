//
//  PennCashNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 5/14/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class PennCashNetworkManager {
    static let instance = PennCashNetworkManager()
    private init() {}
    
    typealias TransactionHandler = (_ csvData: Data?) -> Void
}

extension PennCashNetworkManager: PennAuthRequestable {
    
    private var baseUrl: String {
        return "https://www.penncash.com"
    }
    
    private var transactionsUrl1: String {
        return "https://www.penncash.com/statementnew.php?cid=82&acctto=14&fullscreen=1&wason=/statementnew.php"
    }
    
    private var loginUrl: String {
        return "https://www.penncash.com/login.php"
    }
    
    private var shibbolethUrl: String {
        return "https://www.penncash.com/Shibboleth.sso/SAML2/POST"
    }
    
    func getTransactionHistory(callback: @escaping TransactionHandler) {
//        makeAuthRequest(targetUrl: transactionsUrl1, shibbolethUrl: shibbolethUrl) { (data, response, error) in
//            if let data = data, let html = String(bytes: data, encoding: .utf8) {
//                print(html)
//                let skeyMatches = html.getMatches(for: "skey=(.*?)&")
//                if let skey = skeyMatches.first {
//                    self.getCSVHelper(skey: skey, callback: callback)
//                } else {
//                    print("no skey")
//                }
//            } else {
//                print("went wrong")
//            }
//        }
        getCid { (cid) in
            guard let cid = cid else {
                callback(nil)
                return
            }
            
            self.getSkey(cid: cid) { (skey) in
                guard let skey = skey else {
                    callback(nil)
                    return
                }
                
                self.validateSkey(skey: skey, attemptLimit: 10) { (isValidated) in
                    print(isValidated)
                    if isValidated {
                        self.getCSV(cid: cid, skey: skey) { (_) in
                            
                        }
                    } else {
                        callback(nil)
                    }
                }
            }
        }
    }
    
    private func getCid(_ callback: @escaping (_ cid: String?) -> Void) {
        makeAuthRequest(targetUrl: loginUrl, shibbolethUrl: shibbolethUrl, { (data, response, error) in
            if let data = data, let html = String(bytes: data, encoding: .utf8) {
                let cidMatches = html.getMatches(for: "cid=(.*?)&")
                if let cid = cidMatches.first {
                    callback(cid)
                    return
                }
            }
            callback(nil)
        })
    }
    
    private func getSkey(cid: String, _ callback: @escaping (_ skey: String?) -> Void) {
        let url = "\(self.baseUrl)/login.php?cid=\(cid)&fullscreen=1&wason=/statementnew.php"
        makeAuthRequest(targetUrl: url, shibbolethUrl: shibbolethUrl, { (data, response, error) in
            if let data = data, let html = String(bytes: data, encoding: .utf8) {
                let skeyMatches = html.getMatches(for: "skey=(.*?)\";")
                if let skey = skeyMatches.first {
                    callback(skey)
                    return
                }
            }
            callback(nil)
        })
    }
    
    private func validateSkey(skey: String, attemptLimit: Int, _ callback: @escaping (_ isValidated: Bool) -> Void) {
        if attemptLimit == 0 {
            callback(false)
            return
        }
        
        let url = "\(baseUrl)/login-check.php?skey=\(skey)"
        makeAuthRequest(targetUrl: url, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            if let data = data, let html = String(bytes: data, encoding: .utf8) {
                let isValidated = html.contains("<message>1</message>")
                if isValidated {
                    callback(true)
                } else {
                    print("Failed to validate. No '1' message.")
                    self.validateSkey(skey: skey, attemptLimit: attemptLimit - 1, callback)
                }
            } else {
                print("Failed to validate. No response.")
                self.validateSkey(skey: skey, attemptLimit: attemptLimit - 1, callback)
            }
        }
    }
    
    private func getCSV(cid: String, skey: String, _ callback: @escaping TransactionHandler) {
        let tomorrow = Date().tomorrow
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: tomorrow)
        let csvUrl = "https://www.penncash.com/statementdetail.php?cid=\(cid)&skey=\(skey)&format=csv&startdate=2000-01-01&enddate=\(dateStr)&acct=14"
        makeAuthRequest(targetUrl: csvUrl, shibbolethUrl: shibbolethUrl, { (data, response, error) in
            if let data = data, let str = String(bytes: data, encoding: .utf8) {
//                var results = [[String]]()
                print(str)
//                let rows = str.components(separatedBy: "\n")
//                for row in rows {
//                    let columns = row.components(separatedBy: ";")
////                    result.append(columns)
//                    //print(columns)
//                }
            } else {
                print("something went wrong")
            }
            callback(data)
        })
    }
}

// MARK: - Transaction Parsing
extension PennCashNetworkManager {
}
