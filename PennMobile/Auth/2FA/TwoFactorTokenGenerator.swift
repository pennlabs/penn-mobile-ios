//
//  2FATokenGenerator.swift
//  PennMobile
//
//  Created by Henrique Lorente on 10/8/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import OneTimePassword
import Base32
class TwoFactorTokenGenerator: NSObject{
    
    static let instance = TwoFactorTokenGenerator()
    private override init() {}
    
    func generate(secret: String? = nil) -> String? {

        let name = "PennMobile"
        let issuer = "PennLabs"
        
        var secretString: String?
        if secret == nil {
            let genericPwdQueryable =
                           GenericPasswordQueryable(service: "PennWebLogin")
                       let secureStore =
                           SecureStore(secureStoreQueryable: genericPwdQueryable)
            secretString = try? secureStore.getValue(for: "TOTPSecret")
        } else {
            secretString = secret
        }

        guard let secret = secretString, let secretData = MF_Base32Codec.data(fromBase32String: secret),
            !secretData.isEmpty else {
                print("Invalid secret")
                return nil
        }

        guard let generator = Generator(
            factor: .timer(period: 30),
            secret: secretData,
            algorithm: .sha1,
            digits: 6) else {
                print("Invalid generator parameters")
                return nil
        }

        let token = Token(name: name, issuer: issuer, generator: generator)
        return token.currentPassword
    }
    
}
