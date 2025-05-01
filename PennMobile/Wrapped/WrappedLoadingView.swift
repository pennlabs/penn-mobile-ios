//
//  WrappedLoader.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import Lottie
import Foundation

struct WrappedLoadingView: WrappedStage {
    var activeState: WrappedExperienceState
    let id: UUID = UUID()
    var onFinish: (Bool) -> Void
    
    @EnvironmentObject var vm: WrappedExperienceViewModel
    @State var progress: Double = 0
    
    func start() async {
        await vm.loadModel()
        onFinish(!vm.model.pages.isEmpty)
    }
    
    var body: some View {
        LottieView {
          try await DotLottieFile.named("WrappedLoading")
        }
        .playing(loopMode: .autoReverse)
        .frame(width: 250, height: 250)
        .onAppear {
            Task {
                await start()
            }
        }
    }
}

public struct WrappedLoadingError: Error {
    
}
