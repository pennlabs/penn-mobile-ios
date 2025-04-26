//
//  WrappedHomeScreenBanner.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/23/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

struct WrappedHomeScreenExperience: View {
    
    @ObservedObject var vm: WrappedExperienceViewModel
    
    init(with wrappedModel: WrappedModel) {
        self.vm = WrappedExperienceViewModel(model: wrappedModel)
    }
    
    
    var body: some View {
        ZStack {
            Image("WrappedBanner")
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
                .fullScreenCover(isPresented: $vm.showWrapped) {
                    WrappedExperience([
                        WrappedLoadingView(activeState: .loading) { res in
                            if res {
                                vm.finishedLoading()
                            } else {
                                vm.error(error: WrappedLoadingError())
                            }
                        },
                        WrappedContainerView(activeState: .active) { res in
                            //potentially go to finishing page, but close for right now.
                            vm.showWrapped = false
                        }
                        
                    ])
                    .environmentObject(vm)
                }
        }
        .onTapGesture {
            vm.startExperience()
        }
    }
}


