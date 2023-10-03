//
//  PreferencesView.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/18/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
    @State private var editMode = EditMode.inactive
    @State private var allFeatures = ControllerModel.shared.dynamicFeatures

    var body: some View {
        NavigationView {
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
                        .padding(.vertical, 6)
                    }
                    .onMove(perform: move)
                } header: {
                    Text("Tab Bar")
                } footer: {
                    Text("Choose which features appear in the tab bar. The remaining ones can still be found on the More tab.")
                }
            }
            .environment(\.editMode, Binding.constant(EditMode.active))
        }
        .onAppear {
            let currentTabFeatures = Array(UserDefaults.standard.getTabPreferences()[1...3])
            allFeatures = currentTabFeatures + ControllerModel.shared.dynamicFeatures.filter { !currentTabFeatures.contains($0) }
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
    }
}
