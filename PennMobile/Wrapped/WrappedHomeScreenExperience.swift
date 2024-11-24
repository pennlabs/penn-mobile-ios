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
    @State var wrappedExperienceState: WrappedExperienceState = .inactive
    let wrappedData: WrappedData
    
    init(with wrappedData: WrappedData) {
        self.wrappedData = wrappedData
    }
    
    
    var body: some View {
        let wrappedActive = Binding<Bool>(get: { self.wrappedExperienceState != .inactive }, set: { _ in })
        ZStack {
            Image("WrappedBanner")
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
                .fullScreenCover(isPresented: wrappedActive) {
                    
                }
        }
        .onTapGesture {
            UserDefaults.standard.set(WrappedSemesterState.active.rawValue, forKey: HomeViewData.wrappedSemesters + wrappedData.semester)
            wrappedExperienceState = .loading
        }
    }
}

enum WrappedExperienceState {
    case loading, landing, error, active, inactive, shareScreen, finished
}
