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
    
    func fetchAndSaveTOTPSecret(_ completion: ((_ secret: String?) -> Void)? = nil) {
        let operation = TOTPFetcherOperation { (secret) in
            
            if let secret = secret {
                let genericPwdQueryable =
                    GenericPasswordQueryable(service: "PennWebLogin")
                let secureStore =
                    SecureStore(secureStoreQueryable: genericPwdQueryable)
                try? secureStore.setValue(secret, for: "TOTPSecret")
                guard let ssecret = try? secureStore.getValue(for: "TOTPSecret") else { return }
            }
            completion?(secret)
        }
        operation.run()
    }
    
    class TOTPFetcherOperation {
        
        fileprivate let urlStr = "https://twostep.apps.upenn.edu/twoFactor/twoFactorUi/app/UiMain.index"
        
        var completion: (_ secret: String?) -> Void
        
        init(completion: @escaping (_ secret: String?) -> Void) {
            self.completion = completion
        }
        
        func run() {
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
                        >>> get(by: .attribute("action", "../../twoFactorUi/app/UiMain.totpAdd"))
                        >>> setAttribute("id", value: "TOTPForm") //Add an ID because WKZombie can only submit forms with an ID or name
                        >>> get(by: .id("TOTPForm"))
                        >>> submit
                        >>> get(by: .attribute("action", "UiMain.totpAppIntegrate"))
                        >>> setAttribute("id", value: "TOTPForm2") //This form also needs an ID to be submitted by WKZombie
                        >>> get(by: .id("TOTPForm2"))
                        >>> submit
                        >>> getAll(by: .attribute("style", "white-space: nowrap;")) //There's no easy way to get the code but this returns an array with the code as the first element
                        === self.result
                }
            }
        }
        
        func result(result: Result<[HTMLElement]>) {
            switch result {
            case .success(let value): // handle success
                if !value.isEmpty {
                    self.completion(value[0].text)
                } else {
                    self.completion(nil)
                }
            case .error: // handle error
                // Try to get the token again in case the user was already logged in
                self.getTokenAlreadyLoggedIn()
            }
        }
        
        func getTokenAlreadyLoggedIn() {
            let url = URL(string: self.urlStr)!
            open(url)
                >>> get(by: .attribute("action", "../../twoFactorUi/app/UiMain.totpAdd"))
                >>> setAttribute("id", value: "TOTPForm") //Add an ID because WKZombie can only submit forms with an ID or name
                >>> get(by: .id("TOTPForm"))
                >>> submit
                >>> get(by: .attribute("action", "UiMain.totpAppIntegrate"))
                >>> setAttribute("id", value: "TOTPForm2") //This form also needs an ID to be submitted by WKZombie
                >>> get(by: .id("TOTPForm2"))
                >>> submit
                >>> getAll(by: .attribute("style", "white-space: nowrap;")) //There's no easy way to get the code but this returns an array with the code as the first element
                === self.resultAfterLoggedIn
        }
        
        func resultAfterLoggedIn(result: Result<[HTMLElement]>) {
            switch result {
            case .success(let value): // handle success
                if !value.isEmpty {
                    self.completion(value[0].text)
                } else {
                    self.completion(nil)
                }
            case .error: // handle error
                self.completion(nil)
            }
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
