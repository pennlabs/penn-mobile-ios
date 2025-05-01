//
//  WrappedExperienceViewModel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public class WrappedExperienceViewModel: ObservableObject {
    
    var model: WrappedModel
    @Published var wrappedExperienceState: WrappedExperienceState = .inactive {
        didSet {
            showWrapped = wrappedExperienceState != .inactive
        }
    }
    @Published var showWrapped: Bool = false
    @Published var error: Error?
    @Published var containerVM: WrappedContainerViewModel?
    
    var wrappedUnits: [WrappedUnit] = []
    

    init(model: WrappedModel) {
        self.model = model
    }
    
    func startExperience() {
        wrappedExperienceState = .loading
    }
    
    func loadModel() async {
        await self.model.loadModel()
    }
    
    func finishedLoading() {
        containerVM = WrappedContainerViewModel(units: model.pages)
        wrappedExperienceState = .active
    }
    
    func error(error: any Error) {
        self.error = error
        self.wrappedExperienceState = .error
    }
}


public enum WrappedExperienceState {
    // The idea is that we can make a whole wrapped experience, that consists of multiple stages.
    // Each stage (see WrappedHomeScreenExperience.swift) has an associated state, that controls when that stage is visible.
    
    case loading // Currently loading wrapped animations from model
    case landing // Pre-playback post-load state, if we want to add a start button stage
    case error // Error state, not currently implemented
    case active // Wrapped currently playing (state deferred to WrappedContainerViewModel)
    case inactive // Wrapped not on screen and not loading (default)
    case shareScreen // If we want to implement a share screen with the models (share using native iOS share sheet)
    case finished // Stage for wrap-up tasks if necessary
}
