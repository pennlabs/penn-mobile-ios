//
//  WrappedExperience.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

public struct WrappedExperience: View {
    public var stages: [any WrappedStage]
    @EnvironmentObject var vm: WrappedExperienceViewModel
    
    public init(_ stages: [any WrappedStage]) {
        self.stages = stages
    }
    
    public var body: some View {
        if let active = stages.first(where: {$0.activeState == vm.wrappedExperienceState}) {
            Group {
                if let cVM = vm.containerVM {
                    AnyView(active)
                        .environmentObject(cVM)
                } else {
                    AnyView(active)
                }
            }
            .tag(active.activeState)
        }
    }
}

