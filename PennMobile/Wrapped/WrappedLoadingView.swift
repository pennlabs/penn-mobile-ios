//
//  WrappedLoader.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import Lottie

struct WrappedLoadingView: WrappedStage {
    let id = UUID()
    var onFinish: ((Result<Any?, any Error>) -> Void)
    let activeState: WrappedExperienceState
    @EnvironmentObject var vm: WrappedExperienceViewModel
    @State var progress: Double = 0
    
    func start() async {
        var units: [WrappedUnit] = []
        vm.model.pages.enumerated().forEach { (i, page) in
            Task {
                if let anim = await LottieAnimation.loadedFrom(url: page.lottieUrl) {
                    
                    // TODO REPLACE i WITH the id and sort the array by increasing ids
                    units.append(WrappedUnit(id: i, time: page.time, lottie: anim, values: page.values))
                }
                
                progress += 1 / Double(vm.model.pages.count)
            }
        }
        
        onFinish(!units.isEmpty ? .success(units) : .failure(WrappedLoadingError()))

    }
    
    var body: some View {
        Text("LOADING \(progress)")
    }
}

public struct WrappedLoadingError: Error {
    
}
