//
//  RootView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import LabsPlatformSwift
import PennMobileShared

struct RootView: View {
    @EnvironmentObject var platform: LabsPlatform
    @State private var deepLinkSheet: (@MainActor () -> any View)?

    static let deeplinkHandlers: [DeepLinkHandler.Type] = [
        GSRViewModel.self
    ]

    private var isShowingDeepLinkSheet: Binding<Bool> {
        Binding(get: { deepLinkSheet != nil }, set: { if !$0 { deepLinkSheet = nil } })
    }

    var body: some View {
        Group {
            if platform.isLoggedIn {
                CentralTabs()
            } else {
                LoggedOutView()
            }
        }
        .onOpenURL { url in
            guard url.scheme == "https",
                  url.host == "pennmobile.org" else { return }

            guard let handler: DeepLinkHandler.Type = Self.deeplinkHandlers.first(where: { handler in
                url.path.contains(handler.deepLinkStub)
            }) else { return }

            for intent in handler.handleDeepLink(for: url) {
                if case .openSheet(let view) = intent {
                    deepLinkSheet = view
                }
                
            }
        }
        .sheet(isPresented: isShowingDeepLinkSheet) {
            if let deepLinkSheet {
                AnyView(deepLinkSheet())
            }
        }
    }
}
