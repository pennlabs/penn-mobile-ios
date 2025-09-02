//
//  WrappedHomeScreenBanner.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/23/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import Lottie

struct WrappedHomeScreenExperience: View {
    
    @ObservedObject var vm: WrappedExperienceViewModel
    
    init(with wrappedModel: WrappedModel) {
        self.vm = WrappedExperienceViewModel(model: wrappedModel)
    }
    
    
    var body: some View {
        Button {
            vm.startExperience()
        } label: {
            LottieView {
              try await DotLottieFile.named("WrappedBannerAnim")
            }
            .playing(loopMode: .loop)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $vm.showWrapped) {
            WrappedExperience([
                WrappedLoadingView(activeState: .loading) { res in
                    if res {
                        vm.finishedLoading()
                    } else {
                        vm.error(error: WrappedLoadingError())
                        // Could specify an expierence state that is active when error, but for now,
                        // just close wrapped.
                        vm.wrappedExperienceState = .inactive
                        vm.showWrapped = false
                    }
                },
                WrappedContainerView(activeState: .active) { res in
                    // true result means finished without cancel, false means cancelled
                    if res {
                        //potentially go to finishing page, but close for right now.
                        vm.wrappedExperienceState = .inactive
                        vm.showWrapped = false
                    } else {
                        vm.wrappedExperienceState = .inactive
                        vm.showWrapped = false
                    }
                    
                }
                
            ])
            .environmentObject(vm)
            .ignoresSafeArea()
        }
    }
}


