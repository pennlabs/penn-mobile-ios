//
//  PlatformNetworkManager.swift
//  PennMobile
//
//  Created by Henrique Lorente on 2/23/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

class PlatformNetworkManager: SHA256Hashable, PennAuthRequestable {
   
    static let instance = PlatformNetworkManager()
    
    private var urlStr: String {
           return "https://platform.pennlabs.org/accounts/authorize/?response_type=code&client_id=CJmaheeaQ5bJhRL0xxlxK3b8VEbLb3dMfUAvI2TN&redirect_uri=https%3A%2F%2Fpennlabs.org%2Fpennmobile%2Fios%2Fcallback%2F&code_challenge_method=S256&code_challenge=\(codeChallenge)&scope=read+introspection&state="
       }
    
    private let codeVerifier = String.randomString(length: 64)
       
    private var codeChallenge: String {
        return hash(string: codeVerifier)
    }
    
    private let callbackUrl = "https://pennlabs.org/pennmobile/ios/callback/"
    private let shibbolethUrl = "https://platform.pennlabs.org/Shibboleth.sso/SAML2/POST"
    
    func getAccessTokenUsingCredentials(callback: @escaping (_ result: Result<AccessToken, NetworkingError>) -> Void ) {
        makeAuthRequest(startUrl: urlStr, targetUrl: callbackUrl, requireExactMatch: false, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            guard let url = response?.url?.absoluteString, url.contains(self.callbackUrl), let code = url.split(separator: "=").last else {
                // TODO: Handle failure
                if let error = error as? NetworkingError {
                    callback(.failure(error))
                } else {
                    callback(.failure(.platformAuthError))
                }
                return
            }
            OAuth2NetworkManager.instance.initiateAuthentication(code: String(code), codeVerifier: self.codeVerifier) { (accessToken) in
                if let accessToken = accessToken {
                    callback(.success(accessToken))
                } else {
                    callback(.failure(.platformAuthError))
                }
            }
        }
        
    }
}
