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
                        WrappedLoadingView(onFinish: { res in
                            switch res {
                            case .success(let units):
                                guard let nonNilUnits = units as? [WrappedUnit] else { return }
                                vm.finishedLoading(units: nonNilUnits)
                                break;
                            case .failure(let err):
                                vm.error(error: err)
                            }
                        }, activeState: .loading),
                        WrappedContainerView(onFinish: { res in
                            
                        },
                         activeState: .active,
                         viewModel: WrappedContainerViewModel(units: vm.wrappedUnits))
                    ])
                    .environmentObject(vm)
                }
        }
        .onTapGesture {
            vm.startExperience()
        }
    }
}


