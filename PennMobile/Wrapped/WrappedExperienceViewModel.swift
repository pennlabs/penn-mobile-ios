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
    case loading, landing, error, active, inactive, shareScreen, finished
}
