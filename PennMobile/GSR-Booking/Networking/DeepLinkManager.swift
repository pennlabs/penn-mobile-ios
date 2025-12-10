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
    @Published var lastShareModel: GSRShareModel?

    /// Attempt to parse a domain-based link like:
    /// https://pennmobile.org/ios/gsr/share?shareCode=<8 char share code>
    func handleOpenURL(_ url: URL) throws {
        // 1) Check that it's https + correct host + correct path
        guard url.scheme == "https",
              url.host == "pennmobile.org",
              url.path == "/ios/gsr/share"
        else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let shareCode = components.queryItems?.first(where: { $0.name == "shareCode" })?.value else {
            return
        }
        Task {
            // let root context handle errors
            let model = try await GSRNetworkManager.getShareModelFromShareCode(shareCode: shareCode)
            await MainActor.run {
                self.lastShareModel = model
            }
        }
    }
}

