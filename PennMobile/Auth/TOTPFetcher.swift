//
//  TOTPFetcher.swift
//  PennMobile
//
//  Created by Josh Doman on 10/5/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
import Foundation
// import WKZombie
import WebKit

class TOTPFetcher: NSObject {

    static let instance = TOTPFetcher()
    public var isFetching = false

    private override init() {}

//    func fetchAndSaveTOTPSecret(_ completion: ((_ secret: String?) -> Void)? = nil) {
//        isFetching = true
//        if let _ = UserDefaults.standard.getTwoFactorEnabledDate() {
//            UserDefaults.standard.setTwoFactorEnabledDate(nil)
//        } else {
//            UserDefaults.standard.setTwoFactorEnabledDate(Date())
//        }
//
//        let operation = TOTPFetcherOperation { (secret) in
//            self.isFetching = false
//            if let secret = secret {
//                let genericPwdQueryable =
//                    GenericPasswordQueryable(service: "PennWebLogin")
//                let secureStore =
//                    SecureStore(secureStoreQueryable: genericPwdQueryable)
//                try? secureStore.setValue(secret, for: "TOTPSecret")
//
//                UserDefaults.standard.setTwoFactorEnabledDate(nil)
//            }
//            completion?(secret)
//
//            if (secret != nil) {
//                FirebaseAnalyticsManager.shared.trackEvent(action: .twoStepRetrieval, result: .success, content: true)
//            } else {
//                FirebaseAnalyticsManager.shared.trackEvent(action: .twoStepRetrieval, result: .failed, content: false)
//            }
//        }
//        operation.run()
//    }
//
//    class TOTPFetcherOperation {
//
//        fileprivate let urlStr = "https://twostep.apps.upenn.edu/twoFactor/twoFactorUi/app/UiMain.index"
//
//        var completion: (_ secret: String?) -> Void
//
//        init(completion: @escaping (_ secret: String?) -> Void) {
//            self.completion = completion
//        }
//
//        func run() {
//            TOTPNetworkManager.instance.login {
//                DispatchQueue.main.async {
//                    WKWebsiteDataStore.createDataStoreWithSavedCookies { (dataStore) in
//                        DispatchQueue.main.async {
//                            let zombie = WKZombie(dataStore: dataStore)
//                            Logger.enabled = true
//                            WKZombie.setInstance(zombie: zombie)
//
//                            let url = URL(string: self.urlStr)!
//                            open(url)
//                                === self.checkUrl
//
//                        }
//                    }
//                }
//            }
//        }
//
//        //Check if we need to actually log the user in before getting the TOTP code
//        func checkUrl(result: Result<HTMLPage>) {
//            switch result {
//                case .success(let page):
//                    guard let url = page.url else { return }
//                    if url.absoluteString.contains("weblogin") {
//                        //User was not logged in, so log him in first before going to TOTP Page.
//                        let genericPwdQueryable =
//                            GenericPasswordQueryable(service: "PennWebLogin")
//                        let secureStore =
//                            SecureStore(secureStoreQueryable: genericPwdQueryable)
//                        guard let pennkey = try? secureStore.getValue(for: "PennKey") else { return }
//                        guard let password = try? secureStore.getValue(for: "PennKey Password") else { return }
//
//                        inspect()
//                            >>> get(by: .id("pennname"))
//                            >>> setAttribute("value", value: pennkey)
//                            >>> get(by: .id("password"))
//                            >>> setAttribute("value", value: password)
//                            >>> get(by: .id("login-form"))
//                            >>> submit
//                            === self.goToTOTPPage
//                    }
//                    else {
//                        //User was already logged in, so we just go to the TOTP page
//                        inspect()
//                            === self.goToTOTPPage
//                    }
//                case .error:
//                    self.completion(nil)
//            }
//        }
//
//        func goToTOTPPage(result: Result<HTMLPage>) {
//            inspect()
//                >>> get(by: .attribute("action", "../../twoFactorUi/app/UiMain.totpAdd"))
//                >>> setAttribute("id", value: "TOTPForm") //Add an ID because WKZombie can only submit forms with an ID or name
//                >>> get(by: .id("TOTPForm"))
//                >>> submit
//                >>> get(by: .attribute("action", "UiMain.totpAppIntegrate"))
//                >>> setAttribute("id", value: "TOTPForm2") //This form also needs an ID to be submitted by WKZombie
//                >>> get(by: .id("TOTPForm2"))
//                >>> submit
//                === self.resultAfterLoggedIn
//        }
//
//        func getTokenFromPageAndVerify(page: HTMLPage) {
//            let elementResult = page.findElements(.attribute("style", "white-space: nowrap;"))
//            switch elementResult {
//            case .success(let values):
//                if let secret = values.first?.text {
//                    verifySecret(secret: secret, page: page)
//                    // Go to verification page and verify
//                }
//            case .error: //handle error if TOTP code not found
//                self.completion(nil)
//            }
//        }
//
//        func verifySecret(secret: String, page: HTMLPage) {
//            // Generate 1-time token using secret
//            guard let token = TwoFactorTokenGenerator.instance.generate(secret: secret) else {
//                self.completion(nil)
//                return
//            }
//
//            inspect()
//                >>> get(by: .attribute("action", "UiMain.totpSubmitAppIntegrate"))
//                >>> setAttribute("id", value: "TOTPForm")
//                >>> get(by: .id("TOTPForm"))
//                >>> submit
//                >>> get(by: .name("twoFactorCode"))
//                >>> setAttribute("value", value: token)
//                >>> get(by: .attribute("action", "UiMain.totpSubmitAppCode"))
//                >>> setAttribute("id", value: "TOTPForm")
//                >>> get(by: .id("TOTPForm"))
//                >>> submit
//                >>> get(by: .class("error"))
//                === { (result: Result<HTMLElement>) in
//                    switch result{
//                        case .success(let result): // handle success
//                            guard let r = result.text else { return }
//                            if r.contains("Success: activation code is valid.") {
//                                //The code has been successfully verified, so we can save the TOTP code
//                                self.completion(secret)
//                                NotificationCenter.default.post(name: Notification.Name(rawValue: "TOTPCodeFetched"), object: nil)
//                            }
//                            else {
//                                //The TOTP code was not verified so we have an error
//                                self.completion(nil)
//                            }
//                        case .error: // handle error
//                            self.completion(nil)
//                    }
//            }
//        }
//
//        func resultAfterLoggedIn(result: Result<HTMLPage>) {
//            switch result {
//            case .success(let page): // handle success
//                self.getTokenFromPageAndVerify(page: page)
//            case .error: // handle error
//                self.completion(nil)
//            }
//        }
//    }
}

extension WKWebsiteDataStore {
    static func createDataStoreWithSavedCookies(_ callback: @escaping (WKWebsiteDataStore) -> Void) {
        let wkDataStore = WKWebsiteDataStore.nonPersistent()
        let sharedCookies: [HTTPCookie] = HTTPCookieStorage.shared.cookies ?? []
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
