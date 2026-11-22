//
//  DeepLinkHandler.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/22/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

enum DeepLinkHandlerIntent {
    case switchToAppFeature(feature: FeatureIdentifier)
    case openSheet(view: (@MainActor () -> any View))
}

// To be a DeepLinkHandler, you have to provide some identifier that tells
// Penn Mobile when it should call _your_ handleDeepLink function
// and tell Penn Mobile what it should do (a set of DeepLinkHandlerIntents)
// when it receives one of the links with its stub.
protocol DeepLinkHandler {
    static nonisolated var deepLinkStub: String { get }
    static nonisolated func handleDeepLink(for url: URL) -> [DeepLinkHandlerIntent]
}
