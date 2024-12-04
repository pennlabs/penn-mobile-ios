//
//  WrappedUnitView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/25/24.
//

import SwiftUI
import Lottie

struct WrappedUnitView: View {
    let unit: WrappedUnit
    
    @EnvironmentObject var experienceVM: WrappedExperienceViewModel
    
    var body: some View {
        if var viewModel = experienceVM.containerVM {
            @ObservedObject var vm = viewModel
            GeometryReader { proxy in
                LottieView(animation: unit.lottie)
                    .textProvider(DictionaryTextProvider(unit.values))
                    .playbackMode(vm.activeUnit == unit ? vm.activeUnitPlaybackMode : .paused(at:.currentFrame))
                    .currentProgress(vm.activeUnit == unit ? (CGFloat(vm.activeUnitProgress) * (unit.time / unit.lottie.duration) - floor(CGFloat(vm.activeUnitProgress) * (unit.time / unit.lottie.duration))) : 0)
                    .rotation3DEffect(
                        getAngle(proxy),
                        axis: (x:0, y:1, z:0),
                        anchor: proxy.frame(in:.global).minX > 0 ? .leading : .trailing,
                        perspective: 2.5)
                    .ignoresSafeArea()
                    .onChange(of: getAngle(proxy)) { v in
                        if vm.activeUnit == unit && v.degrees != 0 {
                            vm.pause()
                        } else if (vm.activeUnit == unit) {
                            vm.play()
                        }
                    }
            }
        } else {
            Text("WrappedUnitView appeared unexpectedly")
        }
            
    }
    
    func getAngle(_ proxy: GeometryProxy) -> Angle {
        let progress = proxy.frame(in:.global).minX / proxy.size.width
        let rotationAngle: CGFloat = 45
        let degrees = rotationAngle * progress
        
        return Angle(degrees: Double(degrees))
    }
}
