//
//  WrappedContainerView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/25/24.
//

import SwiftUI
import Foundation

struct WrappedContainerView: WrappedStage {
    var activeState: WrappedExperienceState
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var vm: WrappedExperienceViewModel
    let id: UUID = UUID()
    var onFinish: (Bool) -> Void
    
    var body: some View {
        
        
        if vm.containerVM != nil {
            @ObservedObject var viewModel = vm.containerVM!
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.1)
                    .ignoresSafeArea()
                TabView(selection: $viewModel.activeUnit) {
                    ForEach(vm.containerVM!.units) { unit in
                        WrappedUnitView(unit: unit, vm: vm.containerVM!)
                            .tag(unit)
                    }
                }
                
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    HStack (spacing: 0){
                        ForEach(vm.containerVM!.units, id:\.self) { unit in
                            GeometryReader { proxy in
                                ZStack {
                                    Rectangle()
                                        .size(width: CGFloat((Float(proxy.size.width))), height: 2)
                                        .cornerRadius(1)
                                        .foregroundStyle(.white.opacity(0.5))
                                    if unit.id <= vm.containerVM!.activeUnit.id {
                                        Rectangle()
                                            .size(width: unit.id < vm.containerVM!.activeUnit.id ? proxy.size.width :
                                                    CGFloat((Float(proxy.size.width) * Float(vm.containerVM!.activeUnitProgress))), height: 2)
                                            .cornerRadius(1)
                                            .foregroundStyle(.white)
                                    }
                                }
                            }.padding(.horizontal, 1)
                        }
                    }
                }.foregroundColor(.white)
            }
            .onLongPressGesture(perform: {
                vm.containerVM!.pause()
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }, onPressingChanged: { pressed in
                if !pressed && vm.containerVM!.state == .paused {
                    vm.containerVM!.play()
                }
            })
            .onTapGesture { location in
                if (location.x > 150) {
                    vm.containerVM!.next()
                } else {
                    if (vm.containerVM!.activeUnitProgress > 0.2) {
                        vm.containerVM!.restartCurrent()
                    } else {
                        vm.containerVM!.previous()
                    }
                    
                }
            }
            .onAppear {
                vm.containerVM!.reset()
                vm.containerVM!.play()
            }
            .onChange(of: scenePhase) { new in
                switch (new) {
                case .background, .inactive:
                    vm.containerVM!.pause()
                    break;
                case .active:
                    vm.containerVM!.play()
                    break;
                @unknown default:
                    break;
                }
            }
            .onChange(of: vm.containerVM!.state) { new in
                if (new == .finished) {
                    onFinish(true)
                }
            }
        
        } else {
            Text("Error!")
        }
    }
    
    func start() async {
        vm.containerVM?.play()
    }
    
}
