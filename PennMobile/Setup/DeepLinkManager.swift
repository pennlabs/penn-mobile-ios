//
//  DeepLinkManager.swift
//  PennMobile
//
//  Created by Ximing Luo on 3/2/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation

public class DeepLinkManager {
    public init() {}
    
    /// Attempt to parse a domain-based link like:
    /// https://pennmobile.org/ios/gsr/share?data=<8 char share code>
    public func handleOpenURL(_ url: URL) {
        // 1) Check that it's https + correct host + correct path
        guard url.scheme == "https",
              url.host == "pennmobile.org",
              url.path == "/gsr/share"
        else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let shareCode = components.queryItems?.first(where: { $0.name == "data" })?.value
        else {
            return
        }
        
        //activeSheet = .gsrShare(shareCode: shareCode)
    }
}

