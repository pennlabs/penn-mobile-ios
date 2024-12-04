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
        for (i, page) in vm.model.pages.enumerated() {
            let val = await LottieAnimation.loadedFrom(url: page.lottieUrl)
            if let anim = val {
                // TODO REPLACE i WITH the id and sort the array by increasing ids
                units.append(WrappedUnit(id: i, time: page.time, lottie: anim, values: page.values))
            }
            
            progress += 1 / Double(vm.model.pages.count)
        }
        
        vm.wrappedUnits = units
            
        onFinish(!units.isEmpty)
    }
    
    var body: some View {
        ProgressView(value: progress)
            .onAppear {
                Task {
                    await start()
                }
            }
    }
}

public struct WrappedLoadingError: Error {
    
}
