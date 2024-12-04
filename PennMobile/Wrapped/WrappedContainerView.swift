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
                    ForEach(viewModel.units) { unit in
                        WrappedUnitView(unit: unit)
                            .tag(unit)
                    }
                }
                
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    HStack (spacing: 0){
                        ForEach(viewModel.units, id:\.self) { unit in
                            GeometryReader { proxy in
                                ZStack {
                                    Rectangle()
                                        .size(width: CGFloat((Float(proxy.size.width))), height: 2)
                                        .cornerRadius(1)
                                        .foregroundStyle(.white.opacity(0.5))
                                    if unit.id <= vm.containerVM!.activeUnit.id {
                                        Rectangle()
                                            .size(width: unit.id < viewModel.activeUnit.id ? proxy.size.width :
                                                    CGFloat((Float(proxy.size.width) * Float(viewModel.activeUnitProgress))), height: 2)
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
                viewModel.pause()
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }, onPressingChanged: { pressed in
                if !pressed && viewModel.state == .paused {
                    viewModel.play()
                }
            })
            .onTapGesture { location in
                if (location.x > 150) {
                    viewModel.next()
                } else {
                    if (viewModel.activeUnitProgress > 0.2) {
                        viewModel.restartCurrent()
                    } else {
                        viewModel.previous()
                    }
                    
                }
            }
            .onAppear {
                viewModel.reset()
                viewModel.play()
            }
            .onChange(of: scenePhase) { new in
                switch (new) {
                case .background, .inactive:
                    viewModel.pause()
                    break;
                case .active:
                    viewModel.play()
                    break;
                @unknown default:
                    break;
                }
            }
            .onChange(of: viewModel.state) { new in
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
