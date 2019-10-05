//
//  TOTPFetcher.swift
//  PennMobile
//
//  Created by Josh Doman on 10/5/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WKZombie
import WebKit

class TOTPFetcher: NSObject {
    
    static let instance = TOTPFetcher()
    private override init() {}
    
    fileprivate let urlStr = "https://twostep.apps.upenn.edu/twoFactor/twoFactorUi/app/UiMain.index"
    
    func fetchAndSaveTOTPSecret() {
        let genericPwdQueryable =
            GenericPasswordQueryable(service: "PennWebLogin")
        let secureStore =
            SecureStore(secureStoreQueryable: genericPwdQueryable)
        guard let password = try? secureStore.getValue(for: "PennKey Password") else { return }
        
        _ = WKZombie.sharedInstance
        WKWebsiteDataStore.createDataStoreWithSavedCookies { (dataStore) in
            DispatchQueue.main.async {
                WKZombie.Static.instance = WKZombie(dataStore: dataStore)
                
                let url = URL(string: self.urlStr)!
                open(url)
                    >>> get(by: .id("password"))
                    >>> setAttribute("value", value: password)
                    >>> get(by: .id("loginform"))
                    >>> submit
                    === self.myOutput
            }
        }
    }
    
    func myOutput(result: Result<HTMLPage>) {
        switch result {
        case .success(let value): // handle success
            print(value)
        case .error(let error): // handle error
            print(error)
        }
    }
}

extension WKWebsiteDataStore {
    static func createDataStoreWithSavedCookies(_ callback: @escaping (WKWebsiteDataStore) -> Void) {
        let wkDataStore = WKWebsiteDataStore.nonPersistent()
        let sharedCookies: Array<HTTPCookie> = HTTPCookieStorage.shared.cookies ?? []
        let dispatchGroup = DispatchGroup()
        
        if sharedCookies.count > 0 {
            for cookie in sharedCookies {
                dispatchGroup.enter()
                wkDataStore.httpCookieStore.setCookie(cookie) {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: DispatchQueue.main) {
                callback(wkDataStore)
            }
        } else {
            callback(wkDataStore)
        }
    }
}
