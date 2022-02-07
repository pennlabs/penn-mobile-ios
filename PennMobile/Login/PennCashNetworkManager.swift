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

                self.validateSkey(skey: skey, startTime: Date(), timeLimit: 10) { (isValidated) in
                    if isValidated {
                        self.getCSV(cid: cid, skey: skey, callback: callback)
                    } else {
                        callback(nil)
                    }
                }
            }
        }
    }

    private func getCid(_ callback: @escaping (_ cid: String?) -> Void) {
        makeAuthRequest(targetUrl: loginUrl, shibbolethUrl: shibbolethUrl, { (data, _, _) in
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
        makeAuthRequest(targetUrl: url, shibbolethUrl: shibbolethUrl, { (data, _, _) in
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

    private func validateSkey(skey: String, startTime: Date, timeLimit: TimeInterval, _ callback: @escaping (_ isValidated: Bool) -> Void) {
        if Date().timeIntervalSince(startTime) > timeLimit {
            callback(false)
            return
        }

        let url = "\(baseUrl)/login-check.php?skey=\(skey)"
        makeAuthRequest(targetUrl: url, shibbolethUrl: shibbolethUrl) { (data, _, _) in
            if let data = data, let html = String(bytes: data, encoding: .utf8) {
                let isValidated = html.contains("<message>1</message>")
                if isValidated {
                    callback(true)
                } else {
                    self.validateSkey(skey: skey, startTime: startTime, timeLimit: timeLimit, callback)
                }
            } else {
                callback(false)
            }
        }
    }

    private func getCSV(cid: String, skey: String, callback: @escaping TransactionHandler) {
        let tomorrow = Date().tomorrow
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: tomorrow)
        let csvUrl = "https://www.penncash.com/statementdetail.php?cid=\(cid)&skey=\(skey)&format=csv&startdate=2000-01-01&enddate=\(dateStr)&acct=14"
        makeAuthRequest(targetUrl: csvUrl, shibbolethUrl: shibbolethUrl, { (data, _, _) in
            callback(data)
        })
    }
}
