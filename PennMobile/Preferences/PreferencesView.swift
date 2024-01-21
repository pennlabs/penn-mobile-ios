//
//  PreferencesView.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/18/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
    @State private var allFeatures = ControllerModel.shared.dynamicFeatures
    
    @EnvironmentObject var mainTabViewCoordinator: MainTabViewCoordinator

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(allFeatures.indices, id: \.self) { i in
                        HStack(alignment: .center) {
                            Image(uiImage: ControllerModel.shared.featureIcons[allFeatures[i]]!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 25.0, height: 25.0, alignment: .center)
                                .saturation(i < 3 ? 1 : 0.0)
                            Text(allFeatures[i].rawValue)
                                .foregroundColor(i < 3 ? .primary : .secondary)
                        }
                    }
                    .onMove(perform: move)
                } header: {
                    Text("Drag a feature to the top to pin it.")
                        .foregroundStyle(.primary)
                        .textCase(nil)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                }
            }
            .id(UUID())
            .environment(\.editMode, Binding.constant(EditMode.active))
            .navigationTitle("Edit Features")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            let currentTabFeatures = Array(UserDefaults.standard.getTabPreferences()[1...3])
            allFeatures = currentTabFeatures + ControllerModel.shared.dynamicFeatures.filter { !currentTabFeatures.contains($0) }
            mainTabViewCoordinator.isConfiguringTabs = true
        }
        .onDisappear {
            mainTabViewCoordinator.isConfiguringTabs = false
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        allFeatures.move(fromOffsets: source, toOffset: destination)
        setTabPreferences(tabPreferences: Array(allFeatures[...2]))
    }
}

extension PreferencesView {
    func setTabPreferences(tabPreferences: [Feature]) {
        UserDefaults.standard.setTabPreferences([.home] + tabPreferences + [.more])
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
            .environmentObject(MainTabViewCoordinator())
    }
}
