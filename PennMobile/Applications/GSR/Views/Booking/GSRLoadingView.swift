//
//  GSRLoadingView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Lottie

struct GSRLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            LottieView {
                try await DotLottieFile.named("gsr-loading")
            }
            .playing(loopMode: .autoReverse)
            .frame(width: 250, height: 250)
            Spacer()
        }
    }
}
