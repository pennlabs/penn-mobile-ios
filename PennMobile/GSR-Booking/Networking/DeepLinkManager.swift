//
//  DeepLinkManager.swift
//  PennMobile
//
//  Created by Ximing Luo on 3/2/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

/// Observed by SwiftUI to detect new deep links.
class DeepLinkManager: ObservableObject {
    @Published var lastResolvedLink: GSRShareModel?

    /// Attempt to parse a domain-based link like:
    /// https://pennmobile.org/ios/gsr/share?data=<base64>
    func handleOpenURL(_ url: URL) {
        // 1) Check that it's https + correct host + correct path
        guard url.scheme == "https",
              url.host == "pennmobile.org",
              url.path == "/ios/gsr/share"
        else {
            return
        }
        guard
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems,
            let base64String = queryItems.first(where: { $0.name == "data" })?.value,
            let jsonData = Data(base64Encoded: base64String)
        else {
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let shareModel = try? decoder.decode(GSRShareModel.self, from: jsonData) {
            lastResolvedLink = shareModel
        }
    }
}

