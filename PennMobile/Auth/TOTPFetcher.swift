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
                    >>> get(by: .attribute("action", "../../twoFactorUi/app/UiMain.totpAdd"))
                    >>> setAttribute("id", value: "TOTPForm") //Add an ID because WKZombie can only submit forms with an ID or name
                    >>> get(by: .id("TOTPForm"))
                    >>> submit
                    >>> get(by: .attribute("action", "UiMain.totpAppIntegrate"))
                    >>> setAttribute("id", value: "TOTPForm2") //This form also needs an ID to be submitted by WKZombie
                    >>> get(by: .id("TOTPForm2"))
                    >>> submit
                    >>> getAll(by: .attribute("style", "white-space: nowrap;")) //There's no easy way to get the code but this returns an array with the code as the first element
                    === self.myOutput
            }
        }
    }
    
    func myOutput(result: Result<[HTMLElement]>) {
        switch result {
        case .success(let value): // handle success
            print(value[0].text!) //The first value in the array is the one containing the code
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
