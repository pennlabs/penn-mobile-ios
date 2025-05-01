//
//  WrappedContainerView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/25/24.
//

import SwiftUI
import Foundation

struct WrappedContainerView: WrappedStage {
    static let swipeTransitionEnabled = true
     
    var activeState: WrappedExperienceState
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var vm: WrappedExperienceViewModel
    @EnvironmentObject var containerVM: WrappedContainerViewModel
    let id: UUID = UUID()
    var onFinish: (Bool) -> Void
    
    var body: some View {
        TabView(selection: $containerVM.activeUnit) {
            ForEach(containerVM.units) { unit in
                WrappedUnitView(unit: unit, vm: containerVM)
                    .tag(unit)
            }
        }
        .allowsHitTesting(Self.swipeTransitionEnabled)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .background {
            Color(red: 0.1, green: 0.1, blue: 0.1)
        }
        .overlay {
            VStack {
                HStack (spacing: 0) {
                    ForEach(containerVM.units, id:\.self) { unit in
                        GeometryReader { proxy in
                            ZStack {
                                Rectangle()
                                    .size(width: CGFloat((Float(proxy.size.width))), height: 2)
                                    .cornerRadius(1)
                                    .foregroundStyle(.white.opacity(0.5))
                                if unit.id <= containerVM.activeUnit.id {
                                    Rectangle()
                                        .size(width: unit.id < containerVM.activeUnit.id ? proxy.size.width :
                                                CGFloat((Float(proxy.size.width) * Float(containerVM.activeUnitProgress))), height: 2)
                                        .cornerRadius(1)
                                        .foregroundStyle(.white)
                                }
                            }
                        }.padding(.horizontal, 2)
                        .frame(height: 2)
                    }
                    Button {
                        containerVM.reset()
                        onFinish(false)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .padding(.leading)
                    }
                }
                .padding(.top)
                .shadow(radius: 1)
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal)
        }
        .onLongPressGesture(perform: {
            containerVM.pause()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }, onPressingChanged: { pressed in
            if !pressed && containerVM.state == .paused {
                containerVM.play()
            }
        })
        .onTapGesture { location in
            if (location.x > 150) {
                containerVM.next()
            } else {
                if (containerVM.activeUnitProgress > 0.2) {
                    containerVM.restartCurrent()
                } else {
                    containerVM.previous()
                }
                
            }
        }
        .onAppear {
            containerVM.reset()
            containerVM.play()
        }
        .onChange(of: scenePhase) { new in
            switch (new) {
            case .background, .inactive:
                containerVM.pause()
                break;
            case .active:
                containerVM.play()
                break;
            @unknown default:
                break;
            }
        }
        .onChange(of: containerVM.state) { new in
            if (new == .finished) {
                containerVM.reset()
                onFinish(true)
            }
        }
    }
    
    func start() async {
        vm.containerVM?.play()
    }
    
}
