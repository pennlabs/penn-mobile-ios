//
//  DeepLinkManager.swift
//  PennMobileShared
//
//  Created by Ximing Luo on 3/2/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

/// Observed by SwiftUI to detect new deep links.
public class DeepLinkManager: ObservableObject {
    @Published public var activeSheet: Sheet?
    
    public init() {}
    
    // extendable for other deep linking features in the future
    public enum Sheet: Identifiable {
        case gsrShare(shareCode: String)

        public var id: String {
            switch self {
            case .gsrShare(let code):
                return "gsrShare-\(code)"
            }
        }
    }
    /// Attempt to parse a domain-based link like:
    /// https://pennmobile.org/ios/gsr/share?data=<8 char share code>
    public func handleOpenURL(_ url: URL) {
        print(url)
        // 1) Check that it's https + correct host + correct path
        guard url.scheme == "https",
              url.host == "pennmobile.org",
              url.path == "/gsr/share"
        else {
            print("failed to parse url")
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let shareCode = components.queryItems?.first(where: { $0.name == "data" })?.value
        else {
            print("couldn't extract share code from url")
            return
        }
        
        activeSheet = .gsrShare(shareCode: shareCode)
    }
}

