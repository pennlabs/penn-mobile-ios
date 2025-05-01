//
//  WrappedContainerViewModel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/25/24.
//

import Foundation
import Lottie
import SwiftUI

class WrappedContainerViewModel: ObservableObject {
    
    let units: [WrappedUnit]
    var timer: Timer?
    
    @Published var activeUnit: WrappedUnit {
        didSet {
            activeUnitProgress = 0.0
            self.nextUnit = units.filter({$0.id > activeUnit.id}).sorted(by: {$0.id < $1.id}).first
            self.prevUnit = units.filter({$0.id < activeUnit.id}).sorted(by: {$0.id > $1.id}).first
        }
    }
    @Published var nextUnit: WrappedUnit?
    @Published var prevUnit: WrappedUnit?
    @Published var activeUnitProgress: CGFloat = 0.0 {
        didSet {
            if activeUnitProgress >= 1 {
                withAnimation {
                    next()
                }
            }
        }
    }
    @Published var activeUnitPlaybackMode: LottiePlaybackMode = .paused(at: .frame(0))
    @Published var state: WrappedContainerState = .inactive {
        didSet {
            switch state {
            case .inactive:
                timer?.invalidate()
                timer = nil
                lastFire = nil
                activeUnitPlaybackMode = .paused(at: .frame(0))
            case .paused, .finished:
                timer?.invalidate()
                timer = nil
                lastFire = nil
                activeUnitPlaybackMode = .paused(at: .currentFrame)
                
            case .playing:
                timer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: true) { _ in
                    self.update()
                }
                activeUnitPlaybackMode = .playing(.toProgress(1, loopMode: .loop))
            }
        }
    }
    
    
    var lastFire: Date?
    
    
    public init(units: [WrappedUnit]) {
        self.units = units
        self.activeUnit = units.sorted(by: {$0.id < $1.id}).first!
    }
    
    func reset() {
        if units.isEmpty {
            return
        }
        state = .inactive
        activeUnit = units.sorted(by: {$0.id < $1.id}).first!
    }
    
    func play() {
        if state == .playing {
            return
        }
        state = .playing
    }
    
    func restartCurrent() {
        activeUnitProgress = 0.0
    }
    
    func pause() {
        if state != .playing {
            return
        }
        state = .paused
    }
    
    func next() {
        guard let newActiveUnit = nextUnit else {
            state = .finished
            return
        }
        
        activeUnit = newActiveUnit
    }
    
    func previous() {
        guard let newActiveUnit = prevUnit else {
            restartCurrent()
            return
        }
        
        activeUnit = newActiveUnit
    }
    
    func update() {
        if let lastFireDate = lastFire {
            activeUnitProgress += ((timer?.fireDate.timeIntervalSince(lastFireDate) ?? 0.0) / activeUnit.time!)
        }
        lastFire = timer?.fireDate ?? nil
    }
    
    public enum WrappedContainerState {
        case inactive, paused, playing, finished
    }
    
    
    
    
}
