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
        var units: [WrappedUnit] = []
        for page in vm.model.pages {
            let val = await LottieAnimation.loadedFrom(url: page.lottieUrl)
            if let anim = val {
                units.append(WrappedUnit(id: page.id, time: page.time, lottie: anim, values: page.values))
            }
            
            progress += 1 / Double(vm.model.pages.count)
        }
        
        vm.wrappedUnits = units.sorted(by: { $0.id < $1.id })
        onFinish(!units.isEmpty)
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
