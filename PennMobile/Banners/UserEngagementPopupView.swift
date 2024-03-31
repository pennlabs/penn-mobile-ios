//
//  UserEngagementPopupView.swift
//  PennMobile
//
//  Created by Anthony Li on 3/27/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct UserEngagementPopupView: View {
    static func randomAlignment() -> Alignment {
        [.topTrailing, .bottomTrailing, .bottomLeading, .bottom, .top, .topLeading].randomElement()!
    }
    
    @State var alignment: Alignment = Self.randomAlignment()
    @EnvironmentObject var bannerViewModel: BannerViewModel
    @State var remainingDismissAttempts = 1
    
    var body: some View {
        ZStack(alignment: alignment) {
            VStack(spacing: 0) {
                Text("A personalized offer just for you!")
                    .font(.caption)
                WebView(url: getDefaultPopupURL())
            }
            .ignoresSafeArea()
            
            Button {
                if remainingDismissAttempts <= 0 {
                    bannerViewModel.showPopup = false
                } else {
                    remainingDismissAttempts -= 1
                    self.alignment = Self.randomAlignment()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black)
            }
            .accessibilityLabel("Close")
            .padding()
        }
        .interactiveDismissDisabled()
    }
}
