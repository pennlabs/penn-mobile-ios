//
//  Environment.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 10/2/2022.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

public enum InfoPlistEnvironment {

    enum Keys {
        static let labsOauthClientId = "LABS_OAUTH_CLIENT_ID"
        static let openAIAPIKey = "OPENAI_API_KEY"
    }

    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
          fatalError("Plist file not found")
        }

        return dict
    }()

    static let labsOauthClientId: String = {
        guard let clientId = InfoPlistEnvironment.infoDictionary[Keys.labsOauthClientId] as? String else {
          fatalError("Labs Oath Client Id Key not set in plist for this environment")
        }
        return clientId
    }()
    
    static let openAIAPIKey: String? = {
        InfoPlistEnvironment.infoDictionary[Keys.openAIAPIKey] as? String
    }()
}
